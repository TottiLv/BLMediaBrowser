//
//  UIImage+BLMediaImageDecoder.m
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "UIImage+BLMediaImageDecoder.h"
#import <ImageIO/ImageIO.h>
#import <objc/runtime.h>
#import <mach/mach.h>

/*
 自定义gif的播放,具体步骤如下：

 * 获取当前手机可以利用的内存和当前展示的gif图片每帧图片加载到内存占用的大小,以取得当前内存可以加载gif的最大帧数.
   最大加载帧数 = 可利用内存 /  每帧图片的大小.

 * 使用CADisplayLink作为定时器,开始展示当前帧的图片

 * 获取当前帧的展示时间,展示完毕,切换下一帧图片.当在展示当前帧的图片的时候, 异步线程(自定义NSOperation)去取下一帧的图片,以供当前帧的图片展示
   完毕后,直接从缓存的buffer（字典）中读取.

 * 当gif图片的帧数大于当前内存适合加载的帧数的时候,buffer(字典)会不断的移除已展示过的图片,来确保加载到内存中的图片数稳定.
   如果小于可加载的最大帧数,直接全部加载到内存,节省CPU.

 * BLMediaBrowser为了保证较低的CPU消耗,即使在图片浏览器加载多张gif的时候,也会保证同一时间内,只会对一张gif进行处理,不会同时去解压多张gif图片.
 */
//这里参考了YYImage的源码
#define BUFFER_SIZE (10 * 1024 * 1024) // 10MB (minimum memory buffer size)
static int64_t _YYDeviceMemoryTotal() {
    int64_t mem = [[NSProcessInfo processInfo] physicalMemory];
    if (mem < -1) mem = -1;
    return mem;
}

static int64_t _YYDeviceMemoryFree() {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t page_size;
    vm_statistics_data_t vm_stat;
    kern_return_t kern;
    
    kern = host_page_size(host_port, &page_size);
    if (kern != KERN_SUCCESS) return -1;
    kern = host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    if (kern != KERN_SUCCESS) return -1;
    return vm_stat.free_count * page_size;
}

@interface UIImage ()

@property (nonatomic, setter = blm_setImageSource:,getter=blm_source) CGImageSourceRef blmSource;
@property (nonatomic, setter = blm_setMaxBufferSize:,getter=blm_maxBufferSize) NSNumber *blmMaxBufferSize;

@end

@implementation UIImage (BLMediaImageDecoder)

- (NSNumber *)blm_needUpdateBuffer {
    return objc_getAssociatedObject(self, @selector(blm_needUpdateBuffer));
}

- (void)blm_setNeedUpdateBuffer:(NSNumber *)needUpdateBuffer {
    objc_setAssociatedObject(self, @selector(blm_needUpdateBuffer), needUpdateBuffer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)blm_imageBuffer {
    return objc_getAssociatedObject(self, @selector(blm_imageBuffer));
}
- (void)blm_setImageBuffer:(NSMutableDictionary *)buffer {
    objc_setAssociatedObject(self, @selector(blm_imageBuffer), buffer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGImageSourceRef)blm_source {
    return (__bridge CGImageSourceRef)objc_getAssociatedObject(self, @selector(blm_source));
}
- (void)blm_setImageSource:(CGImageSourceRef)source {
    objc_setAssociatedObject(self, @selector(blm_source), (__bridge id)(source), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)blm_handleIndex {
    return objc_getAssociatedObject(self, @selector(blm_handleIndex));
}
- (void)blm_setHandleIndex:(NSNumber *)handleIndex {
    objc_setAssociatedObject(self, @selector(blm_handleIndex), handleIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)blm_totalFrameCount {
    return objc_getAssociatedObject(self, @selector(blm_totalFrameCount));
}
- (void)blm_setTotalFrameCount:(NSNumber *)totalFrameCount{
    objc_setAssociatedObject(self, @selector(blm_totalFrameCount), totalFrameCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)blm_maxBufferCount {
    return objc_getAssociatedObject(self, @selector(blm_maxBufferCount));
}
- (void)blm_setMaxBufferCount:(NSNumber *)maxBufferCount{
    objc_setAssociatedObject(self, @selector(blm_maxBufferCount), maxBufferCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)blm_maxBufferSize {
    return objc_getAssociatedObject(self, @selector(blm_maxBufferSize));
}
- (void)blm_setMaxBufferSize:(NSNumber *)blm_maxBufferSize{
    objc_setAssociatedObject(self, @selector(blm_maxBufferSize), blm_maxBufferSize, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)blm_bufferMiss {
    return objc_getAssociatedObject(self, @selector(blm_bufferMiss));
    
}
- (void)blm_setBufferMiss:(NSNumber *)bufferMiss {
    objc_setAssociatedObject(self, @selector(blm_bufferMiss), bufferMiss, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}
- (NSNumber *)blm_incrBufferCount {
    return objc_getAssociatedObject(self, @selector(blm_incrBufferCount));
}
- (void)blm_setIncrBufferCount:(NSNumber *)incrBufferCount {
    objc_setAssociatedObject(self, @selector(blm_incrBufferCount), incrBufferCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
#pragma mark - 这里是老版的SDWebImage提供的加载Gif的动画的方法 新版取消了 只默认取gif的第一帧
// 高内存 低cpu --> 对较大的gif图片来说  内存会很大
+ (UIImage *)sdOverdueAnimatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            duration += [self sdOverdue_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)sdOverdue_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    CFRelease(cfFrameProperties);
    
    return frameDuration;
}

- (void)animatedGIFData:(NSData *)data {
    if (!data) {
        return;
    }
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    [self blm_setImageSource:source];
    [self calcMaxBufferCount];
    size_t count = CGImageSourceGetCount(source);
    // 需要不停地解压-->
    [self blm_setImageBuffer:[NSMutableDictionary dictionary]];
    [self blm_setHandleIndex:@(0)];
    [self blm_setBufferMiss:@(NO)];
    [self blm_setIncrBufferCount:@(0)];
    [self blm_setTotalFrameCount:@(count)];
    if (count > self.maxBufferCount.intValue) {
        [self blm_setNeedUpdateBuffer:@(YES)];
    }
}

- (NSTimeInterval)animatedImageDurationAtIndex:(int)index {
    return [self.class sdOverdue_frameDurationAtIndex:index source:self.blm_source];
}

- (UIImage *)animatedImageFrameAtIndex:(int)index {
    CGImageRef cgImage = NULL;
    cgImage = CGImageSourceCreateImageAtIndex(self.blm_source, index, NULL);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(cgImage);
    return image;
}

- (void)imageViewShowFinsished {
    if (self.blm_source) {
        NSMutableDictionary *buffer = [self blm_imageBuffer];
        [buffer removeAllObjects];
        CGImageSourceRef source = self.blm_source;
        CFRelease(source);
        objc_removeAssociatedObjects(self);
    }
}

#pragma mark- private
- (void)calcMaxBufferCount { // 合适的加载图片数目
    // 1 获取每帧的图片内存占用大小
    CGImageRef image  = CGImageSourceCreateImageAtIndex(self.blm_source, 0, NULL);
    NSUInteger bytesPerFrame = CGImageGetBytesPerRow(image) * CGImageGetHeight(image);
    
    int64_t bytes = (int64_t)bytesPerFrame;
    if (bytes == 0) bytes = 1024;
    int64_t total = _YYDeviceMemoryTotal();
    int64_t free = _YYDeviceMemoryFree();
    int64_t max = MIN(total * 0.2, free * 0.6);
    max = MAX(max, BUFFER_SIZE);
    // 获取到最多可以加载的图片数
    double maxBufferCount = (double)max / (double)bytes;
    if (maxBufferCount < 1) maxBufferCount = 1;
    else if (maxBufferCount > 512) maxBufferCount = 512;
    [self blm_setMaxBufferCount:@(maxBufferCount)];
    CGImageRelease(image);

}


@end
