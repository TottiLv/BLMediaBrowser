//
//  BLMediaBrowserView.h
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLMediaBrowserConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface BLMediaBrowserView : UIWindow

- (void)showImageViewsWithURLs:(BLMediaUrlsMutableArray *)urls andSelectedIndex:(int)index;

- (void)showImageViewsWithImages:(BLMediaImagesMutableArray *)images andSeletedIndex:(int)index;

@end

@interface BLMediaScrollViewStatusModel : NSObject

@property (nonatomic, strong) NSNumber *scale;
@property (nonatomic, assign) CGPoint contentOffset;

@property (nonatomic, strong) UIImage *currentPageImage;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) id opreation;

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL showPopAnimation;
@property (nonatomic, assign) int index;

@property (nonatomic, copy)void (^loadImageCompletedBlock)(BLMediaScrollViewStatusModel *loadModel,UIImage *image, NSData *data, NSError *  error, BOOL finished, NSURL *imageURL);

- (void)loadImageWithCompletedBlock:(void (^)(BLMediaScrollViewStatusModel *loadModel,UIImage *image, NSData *data, NSError *  error, BOOL finished, NSURL *imageURL))completedBlock;
@end

NS_ASSUME_NONNULL_END
