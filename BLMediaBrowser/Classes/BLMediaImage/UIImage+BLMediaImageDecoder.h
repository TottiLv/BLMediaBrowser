//
//  UIImage+BLMediaImageDecoder.h
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (BLMediaImageDecoder)

//存储图片
@property (nonatomic, setter = blm_setImageBuffer:,getter=blm_imageBuffer) NSMutableDictionary *buffer;

//是否需要不停刷新buffer
@property (nonatomic, setter = blm_setNeedUpdateBuffer:,getter=blm_needUpdateBuffer) NSNumber *needUpdateBuffer;

// 当前展示到那一张图片了
@property (nonatomic, setter = blm_setHandleIndex:,getter=blm_handleIndex) NSNumber *handleIndex;

// 最大的缓存图片数
@property (nonatomic, setter = blm_setMaxBufferCount:,getter=blm_maxBufferCount) NSNumber *maxBufferCount;

// 当前这帧图像是否展示
@property (nonatomic, setter = blm_setBufferMiss:,getter=blm_bufferMiss) NSNumber *bufferMiss;

// 增加的buffer数目
@property (nonatomic, setter = blm_setIncrBufferCount:,getter=blm_incrBufferCount)NSNumber *incrBufferCount;

// 该gif 一共多少帧
@property (nonatomic, setter = blm_setTotalFrameCount:,getter=blm_totalFrameCount)NSNumber *totalFrameCount;

+ (UIImage *)sdOverdueAnimatedGIFWithData:(NSData *)data;

- (void)animatedGIFData:(NSData *)data;

- (NSTimeInterval)animatedImageDurationAtIndex:(int)index;

- (UIImage *)animatedImageFrameAtIndex:(int)index;

- (void)imageViewShowFinsished;


@end

NS_ASSUME_NONNULL_END
