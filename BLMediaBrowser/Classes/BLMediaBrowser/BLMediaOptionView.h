//
//  BLMediaOptionView.h
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLMediaOptionView : UIView

@property (nonatomic , strong)UIImage *image;

+ (instancetype)showOptionView;
+ (instancetype)showOptionViewWithCurrentCellImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
