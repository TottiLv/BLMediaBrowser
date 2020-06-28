//
//  BLMediaLoadingView.h
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLMediaLoadingView : UIView

/// 显示loading
/// @param text 文本内容
/// @param superView 父视图
/// @param second 几秒后dismiss
+ (UILabel *)showText:(NSString *)text toView:(UIView *)superView dismissAfterSecond:(NSTimeInterval)second;

@end

NS_ASSUME_NONNULL_END
