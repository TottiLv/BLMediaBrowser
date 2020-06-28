//
//  UIView+BLMediaViewFrame.h
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (BLMediaViewFrame)

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic,assign) CGFloat centerX;
@property (nonatomic,assign) CGFloat centerY;

@end

NS_ASSUME_NONNULL_END
