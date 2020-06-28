//
//  BLMediaZoomScrollView.m
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//
#import <CoreGraphics/CoreGraphics.h>
#import "BLMediaZoomScrollView.h"
#import "BLMediaBrowserConst.h"
#import "BLMediaLoadingView.h"
#import "BLMediaTapDetectingImageView.h"
#import "BLMediaBrowserManager.h"
#import "BLMediaBrowserView.h"
#import "UIView+BLMediaViewFrame.h"

#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDImageCacheConfig.h>
#import <SDWebImage/UIImage+MultiFormat.h>
#import <SDWebImage/UIImage+GIF.h>
#else
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"
#import "SDImageCacheConfig.h"
#import "UIImage+MultiFormat.h"
#import "UIImage+GIF.h"
#endif

static inline CGRect moveSizeToCenter(CGSize size) {
    return CGRectMake(BL_MEDIA_SCREEN_WIDTH /2.0 - size.width / 2.0, BL_MEDIA_SCREEN_HEIGHT /2.0 - size.height / 2.0, size.width, size.height);
}

static CGFloat scrollViewMinZoomScale = 1.0;
static CGFloat scrollViewMaxZoomScale = 3.0;

@interface BLMediaZoomScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, weak)     BLMediaLoadingView *loadingView;
@property (nonatomic, assign)   CGSize imageSize;
@property (nonatomic, assign)   CGRect oldFrame;

@end


@implementation BLMediaZoomScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.alwaysBounceVertical = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.frame = CGRectMake(10, 0, BL_MEDIA_SCREEN_WIDTH, BL_MEDIA_SCREEN_HEIGHT);
        self.panGestureRecognizer.delegate = self;
        self.minimumZoomScale = scrollViewMinZoomScale;
        [self imageView];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    // 图片在移动的时候停止居中布局
    if (self.imageViewIsMoving == YES) return;

    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter =  self.imageView.frame;
    // Horizontally floor：如果参数是小数，则求最大的整数但不大于本身.
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }

    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    // Center
    if (!CGRectEqualToRect( self.imageView.frame, frameToCenter)){
        self.imageView.frame = frameToCenter;
    }
  
}

#pragma mark- public
//点击图片，进入到大图，调用此方法
- (void)startPopAnimationWithModel:(BLMediaScrollViewStatusModel *)model completionBlock:(void (^)(void))completion {
    NSLog(@"------------startPopAnimationWithModel------------");
    UIImage *currentImage = model.currentPageImage;
    _model = model;
    if (!currentImage) {
        currentImage = [self getPlaceholdImageForModel:model];
    }
    [self showPopAnimationWithImage:currentImage WithCompletionBlock:completion];
}

#pragma mark - imageView点击事件的处理方法

- (void)handlesingleTap:(CGPoint)touchPoint {
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    if ([[BLMediaBrowserManager defaultManager].imageViewSuperView isKindOfClass:[UICollectionView class]]) {
        [self configCollectionViewAnimationStyle];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BLMediaImageViewWillDismissNot" object:nil];
    BLMediaBrowserManager *mgr = [BLMediaBrowserManager defaultManager];
    CGRect currentViewFrame =  [mgr.frames[mgr.currentPage] CGRectValue];
    self.oldFrame = [mgr.imageViewSuperView convertRect:currentViewFrame toView:[UIApplication sharedApplication].keyWindow];
    UIImageView *dismissView = self.imageView;
    self.imageViewIsMoving = YES;
    weak_self;
    [UIView animateWithDuration:0.2 animations:^{
        wself.zoomScale = scrollViewMinZoomScale;
        wself.contentOffset = CGPointZero;
        dismissView.frame = wself.oldFrame;
        dismissView.contentMode = UIViewContentModeScaleAspectFill;
        dismissView.clipsToBounds = YES;
        if (wself.model.currentPageImage.images.count > 0) {
            dismissView.image = wself.model.currentPageImage;
        }
        [BLMediaBrowserManager defaultManager].currentCollectionView.superview.backgroundColor = [UIColor clearColor];
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            wself.imageView.alpha = 0;
        } completion:^(BOOL finished) {
            [dismissView removeFromSuperview];
            [wself removeFromSuperview];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BLMediaImageViewDidDismissNot" object:nil];
        }];
    }];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    if (self.maximumZoomScale == self.minimumZoomScale) {
        return;
    }
    
    if (self.zoomScale != self.minimumZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        //227,148,125,270
        CGFloat newZoomScale = self.maximumZoomScale ;
        CGFloat xsize = self.bounds.size.width / newZoomScale;
        CGFloat ysize = self.bounds.size.height / newZoomScale;
        [self zoomToRect:CGRectMake(touchPoint.x - xsize/2, touchPoint.y - ysize/2, xsize, ysize) animated:YES];
    }
}

- (void)configCollectionViewAnimationStyle {
    NSDictionary *info = [BLMediaBrowserManager defaultManager].linkageInfo;
    NSString *reuseIdentifier = info[@"blmedia_reuseIdentifier"];
    if (!reuseIdentifier) {
        NSLog(@"请设置传入collectionViewCell的reuseIdentifier");
    }
    NSUInteger style = UICollectionViewScrollPositionCenteredHorizontally;
    if (info[@"blmedia_style"]) {
        style = [info[@"blmedia_style"] unsignedIntValue];
    }
    UICollectionView *collectionView = (UICollectionView *)[BLMediaBrowserManager defaultManager].imageViewSuperView;
    NSIndexPath *index = [NSIndexPath indexPathForItem:[BLMediaBrowserManager defaultManager].currentPage inSection:0];
    [collectionView scrollToItemAtIndexPath:index atScrollPosition:style animated:NO];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:index];
    NSValue* value  = [NSValue valueWithCGRect:cell.frame];
    [[BLMediaBrowserManager defaultManager].frames replaceObjectAtIndex:index.row withObject:value];
}

#pragma mark- private
- (void)showPopAnimationWithImage:(UIImage *)image WithCompletionBlock:(void (^)(void))completion {
    weak_self;
    NSLog(@"------------showPopAnimationWithImage------------");
    BLMediaBrowserManager *manager = [BLMediaBrowserManager defaultManager];
    CGRect animationViewFrame = [manager.frames[manager.currentPage]  CGRectValue];
    CGRect rect = [manager.imageViewSuperView convertRect: animationViewFrame toView:[UIApplication sharedApplication].keyWindow];
    self.oldFrame = rect;
    CGRect photoImageViewFrame;
    CGSize size = manager.placeholdImageSizeBlock ? manager.placeholdImageSizeBlock(image, [NSIndexPath indexPathForItem:self.model.index inSection:0]) : CGSizeZero;
    if (!CGSizeEqualToSize(size, CGSizeZero) && !self.model.currentPageImage) {
        photoImageViewFrame = moveSizeToCenter(size);
    }else {
        [self resetScrollViewStatusWithImage:image];
        photoImageViewFrame = self.imageView.frame;
    }
    self.imageViewIsMoving = YES;
    self.imageView.frame = self.oldFrame;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut animations:^{
        wself.imageView.frame = photoImageViewFrame;
    }completion:^(BOOL finished) {
        wself.imageViewIsMoving = NO;
        [wself layoutSubviews];// sometime need layout
        if (completion) {
            NSLog(@"---------------------completion----------------------");
            completion();
        }
    }];
    // if not clear this image ,gif image may have some thing wrong
    self.imageView.image = nil;
    self.imageView.image = image;
    [self setNeedsLayout];
}

- (void)resetScrollViewStatusWithImage:(UIImage *)image {
    NSLog(@"------------resetScrollViewStatusWithImage------------");
    self.zoomScale = scrollViewMinZoomScale;
    self.imageView.frame = CGRectMake(0, 0, self.width, 0);
    if (image.size.height / image.size.width > self.height / self.width) {
        self.imageView.height = floor(image.size.height / (image.size.width / self.width));
    }else {
        CGFloat height = image.size.height / image.size.width * self.width;;
        self.imageView.height = floor(height);
        self.imageView.centerY = self.height / 2;
    }
    if (self.imageView.height > self.height && self.imageView.height - self.height <= 1) {
        self.imageView.height = self.height;
    }
    self.contentSize = CGSizeMake(self.width, MAX(self.imageView.height, self.height));
    [self setContentOffset:CGPointZero];
    
    if (self.imageView.height > self.height) {
        self.alwaysBounceVertical = YES;
    } else {
        self.alwaysBounceVertical = NO;
    }

    if (self.imageView.contentMode != UIViewContentModeScaleToFill) {
        self.imageView.contentMode =  UIViewContentModeScaleToFill;
        self.imageView.clipsToBounds = NO;
    }
}

- (UIImage *)getPlaceholdImageForModel:(BLMediaScrollViewStatusModel *)model {
    BLMediaBrowserManager *manager = [BLMediaBrowserManager defaultManager];
    UIImage *placeholdImage = nil;
    if (manager.placeholdImageCallBackBlock) {
        placeholdImage =  manager.placeholdImageCallBackBlock([NSIndexPath indexPathForItem:model.index inSection:0]);
        if (!placeholdImage) {
            placeholdImage =[UIImage imageNamed:@"BLMediaLoading.png"];
        }
    }else {
        placeholdImage =[UIImage imageNamed:@"BLMediaLoading.png"];
    }
    return placeholdImage;
}

- (void)setModel:(BLMediaScrollViewStatusModel *)model {
    _model = model;
    weak_self;
    [self removePreviousFadeAnimationForLayer:self.imageView.layer];
    BLMediaBrowserManager *manager = [BLMediaBrowserManager defaultManager];
    if (!model.currentPageImage) {
        [self loadingView];
        wself.maximumZoomScale = scrollViewMinZoomScale;
        CGSize size = manager.placeholdImageSizeBlock ? manager.placeholdImageSizeBlock([self getPlaceholdImageForModel:model],[NSIndexPath indexPathForItem:model.index inSection:0]) : CGSizeZero;
        if (!CGSizeEqualToSize(size, CGSizeZero)) {
            self.imageView.frame = moveSizeToCenter(size);
        }else {
            [self resetScrollViewStatusWithImage:[self getPlaceholdImageForModel:model]];
        }
        self.imageView.image = [self getPlaceholdImageForModel:model];
        [model loadImageWithCompletedBlock:^(BLMediaScrollViewStatusModel *loadModel, UIImage *image, NSData *data, NSError *error, BOOL finished, NSURL *imageURL) {
            [wself.loadingView removeFromSuperview];
            wself.maximumZoomScale = scrollViewMaxZoomScale;
            if (error) {
                image = manager.errorImage;
                NSLog(@"%@",error);
            }
            model.currentPageImage  = image;
            if (image.images.count > 0) {
#pragma mark-- TODO
                //sdOverdue_animatedGIFWithData
                model.currentPageImage = manager.lowGifMemory ? image : [UIImage sd_imageWithGIFData:data];
            }
            // 下载完成之后 只有当前cell正在展示 --> 刷新
            NSArray *cells = [manager.currentCollectionView visibleCells];
            for (id obj in cells) {
                BLMediaScrollViewStatusModel *visibleModel = [obj valueForKeyPath:@"model"];
                if (model.index == visibleModel.index) {
                    [wself reloadCellDataWithModel:model andImage:image andImageData:data];
                }
            }
        }];
    }else {
        if (_loadingView) {
            [_loadingView removeFromSuperview];
        }
        [self resetScrollViewStatusWithImage:model.currentPageImage];
        /**
          when lowGifMemory = NO,if not clear this image ,gif image may have some thing wrong
         */
        self.imageView.image = nil;
        self.imageView.image = model.currentPageImage;
        self.maximumZoomScale = scrollViewMaxZoomScale;
    }
    self.zoomScale = model.scale.floatValue;
    self.contentOffset = model.contentOffset;
}

- (void)reloadCellDataWithModel:(BLMediaScrollViewStatusModel *)model andImage:(UIImage *)image andImageData:(NSData *)data{
    BLMediaBrowserManager *manager = [BLMediaBrowserManager defaultManager];
    self.imageView.image = model.currentPageImage;
    [self resetScrollViewStatusWithImage:model.currentPageImage];
    CGSize size = manager.placeholdImageSizeBlock ? manager.placeholdImageSizeBlock([self getPlaceholdImageForModel:model], [NSIndexPath indexPathForItem:model.index inSection:0]) : CGSizeZero;
    if (!CGSizeEqualToSize(size, CGSizeZero)) {
        CGRect imageViewFrame = self.imageView.frame;
        self.imageView.frame = moveSizeToCenter(size);
        [UIView animateWithDuration:0.25 animations:^{
            self.imageView.frame = imageViewFrame;
        }];
    }else {
        [self addFadeAnimationWithDuration:0.25 curve:UIViewAnimationCurveLinear ForLayer:self.imageView.layer];
    }
    /**
     当gif下载完成 并且正在当前的展示状态的时候
     由于SDWebImage异步下载图片 导致可能图片没有完全写入沙盒 故:
     */
    if (image.images.count > 0 && model.index == manager.currentPage && manager.lowGifMemory) {
        [manager setValue:data forKey:@"spareData"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BLMediaGifImageDownloadFinishedNot" object:nil];
        });
    }
}

#pragma mark - getter
- (BLMediaTapDetectingImageView *)imageView {
    if (!_imageView) {
        BLMediaTapDetectingImageView *imageView  = [[BLMediaTapDetectingImageView alloc]init];
        [self addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}

- (BLMediaLoadingView *)loadingView {
    if (!_loadingView) {
        BLMediaLoadingView *loadingView = [[BLMediaLoadingView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        loadingView.frame = moveSizeToCenter(loadingView.frame.size);
        [self addSubview:loadingView];
        _loadingView = loadingView;
    }
    return _loadingView;
}


#pragma mark- animation
- (void)addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve ForLayer:(CALayer *)layer{
    if (duration <= 0) return;
    NSString *mediaFunction;
    switch (curve) {
        case UIViewAnimationCurveEaseInOut: {
            mediaFunction = kCAMediaTimingFunctionEaseInEaseOut;
        } break;
        case UIViewAnimationCurveEaseIn: {
            mediaFunction = kCAMediaTimingFunctionEaseIn;
        } break;
        case UIViewAnimationCurveEaseOut: {
            mediaFunction = kCAMediaTimingFunctionEaseOut;
        } break;
        case UIViewAnimationCurveLinear: {
            mediaFunction = kCAMediaTimingFunctionLinear;
        } break;
        default: {
            mediaFunction = kCAMediaTimingFunctionLinear;
        } break;
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = duration;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:mediaFunction];
    transition.type = kCATransitionFade;
    [layer addAnimation:transition forKey:@"blmedia.fade"];
}

- (void)removePreviousFadeAnimationForLayer:(CALayer *)layer {
    [layer removeAnimationForKey:@"blmedia.fade"];
}

#pragma mark - UIScrollViewDelegate
//告诉scrollView，要缩放的是哪个子控件
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    NSLog(@"---------------viewForZoomingInScrollView--------------");
    return self.imageView;
}

//正在缩放的时候调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    NSLog(@"---------------scrollViewDidZoom--------------");
    if (self.model.isShowing == NO) return;
    self.model.scale = @(scrollView.zoomScale);
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if (scrollView.minimumZoomScale != scale) return;
    [self setZoomScale:self.minimumZoomScale animated:YES];
//    [self resetScrollViewStatusWithImage:self.model.currentPageImage];
    [self setNeedsLayout];
    [self layoutIfNeeded];

}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.model.isShowing == NO) return;
    self.model.contentOffset = scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.imageView.height > [UIScreen mainScreen].bounds.size.height) {
        [[BLMediaBrowserManager defaultManager].currentCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.model.index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    }
}

@end
