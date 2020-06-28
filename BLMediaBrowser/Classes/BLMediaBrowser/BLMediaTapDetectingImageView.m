//
//  BLMediaTapDetectingImageView.m
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLMediaTapDetectingImageView.h"
#import "BLMediaBrowserManager.h"
#import "BLMediaZoomScrollView.h"
#import "BLMediaBrowserView.h"
#import "BLMediaOptionView.h"

@interface BLMediaTapDetectingImageView ()

@property (nonatomic, weak) UIView *optionView;

@end

@implementation BLMediaTapDetectingImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        UILongPressGestureRecognizer *ges = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction)];
        [self addGestureRecognizer:ges];
    }
    return self;
}

- (void)longPressAction {
    BLMediaBrowserManager *manager = [BLMediaBrowserManager defaultManager];
    if (!manager.currentTitles || manager.currentTitles.count == 0) {
        return;
    }
    [self optionView];
}

- (UIView *)optionView {
    if (_optionView) return _optionView;
    BLMediaBrowserManager *manager = [BLMediaBrowserManager defaultManager];
    if (manager.longPressCustomViewBlock) {
        UIView *optionView = manager.longPressCustomViewBlock(self.image,[NSIndexPath indexPathForRow:manager.currentPage inSection:0]);
        [[UIApplication sharedApplication].keyWindow addSubview:optionView];
        _optionView = optionView;
    }else {
        BLMediaZoomScrollView *scrollView =  (BLMediaZoomScrollView *)self.superview;
        _optionView = [BLMediaOptionView showOptionViewWithCurrentCellImage:scrollView.model.currentPageImage];
    }
    return _optionView;
}

@end
