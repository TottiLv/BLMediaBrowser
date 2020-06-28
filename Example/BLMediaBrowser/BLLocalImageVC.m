//
//  BLLocalImageVC.m
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLLocalImageVC.h"
#import <BLMediaBrowser/UIView+BLMediaViewFrame.h>
#import <BLMediaBrowser/BLMediaBrowserManager.h>

#define MAX_COUNT 10
#define BL_WEAK_SELF __weak typeof(self)wself = self
@interface BLLocalImageVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic , strong)NSMutableArray *frames;
@property (nonatomic , weak)UIButton *addBtn;
@property (nonatomic , strong)NSMutableArray *imageViews;
@end

@implementation BLLocalImageVC

- (void)dealloc {
    NSLog(@"%@ 销毁了",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.frames = @[].mutableCopy;
    self.imageViews = @[].mutableCopy;
    BL_WEAK_SELF;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int column = 3;
        CGFloat itemWidth = ([UIScreen mainScreen].bounds.size.width - 2 * 10) / 3;
        CGFloat itemHeight = itemWidth;
        for (int i = 0; i < MAX_COUNT; i++) {
            CGFloat x = (i % column) * (10 + itemWidth) ;
            CGFloat y = (i / column) * (10 + itemHeight);
            CGRect frame = CGRectMake(x,100 + y, itemWidth, itemHeight);
            [wself.frames addObject:[NSValue valueWithCGRect:frame]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            UIButton *addBtn = [[UIButton alloc]initWithFrame:[wself.frames.firstObject CGRectValue]];
            addBtn.backgroundColor = [UIColor lightGrayColor];
            [addBtn setTitle:@"添加" forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(getImageFromIpc) forControlEvents:UIControlEventTouchDown];
            [wself.view addSubview:addBtn];
            wself.addBtn = addBtn;
        });
    });
}


- (void)getImageFromIpc
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) return;
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [self presentViewController:ipc animated:YES completion:nil];
}

#pragma mark -- <UIImagePickerControllerDelegate>--
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    BL_WEAK_SELF;
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:[wself.frames.firstObject CGRectValue]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageClick:)];
        [imageView addGestureRecognizer:tap];
        imageView.clipsToBounds = YES;
        imageView.tag = MAX_COUNT - wself.frames.count;
        imageView.userInteractionEnabled = YES;
        imageView.image = image;
        [wself.view addSubview:imageView];
        [wself.view bringSubviewToFront:wself.addBtn];
        [wself.imageViews addObject:imageView];
        [wself.frames removeObjectAtIndex:0];
        if (!wself.frames.firstObject) {
            [wself.addBtn removeFromSuperview];
        }else {
            [UIView  animateWithDuration:0.25 animations:^{
                wself.addBtn.frame = [wself.frames.firstObject CGRectValue];
            }];
        }
    }];
   
}

- (void)imageClick:(UITapGestureRecognizer *)tap {
    NSMutableArray *items = @[].mutableCopy;
    for (UIImageView *imageView in self.imageViews) {
        BLMediaLocalItem *item = [[BLMediaLocalItem alloc]initWithImage:imageView.image frame:imageView.frame];
        [items addObject:item];
    }
    // 这里只要你开心 可以无限addBlock
    [[[[BLMediaBrowserManager defaultManager] showImageWithLocalItems:items selectedIndex:tap.view.tag fromImageViewSuperView:self.view] addLongPressShowTitles:@[@"保存图片",@"识别二维码",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
        NSLog(@"%@",title);
    }];
}

@end
