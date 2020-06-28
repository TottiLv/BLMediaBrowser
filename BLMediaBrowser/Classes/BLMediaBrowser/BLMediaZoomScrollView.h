//
//  BLMediaZoomScrollView.h
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLMediaTapDetectingImageView.h"
NS_ASSUME_NONNULL_BEGIN
@class BLMediaScrollViewStatusModel;
@interface BLMediaZoomScrollView : UIScrollView

@property (nonatomic, strong) BLMediaScrollViewStatusModel *model;

@property (nonatomic, weak) BLMediaTapDetectingImageView *imageView;

@property (nonatomic, assign) BOOL imageViewIsMoving;

- (void)handlesingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;
- (void)startPopAnimationWithModel:(BLMediaScrollViewStatusModel *)model completionBlock:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
