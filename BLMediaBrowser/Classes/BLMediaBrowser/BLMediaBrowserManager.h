//
//  BLMediaBrowserManager.h
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLMediaBrowserConst.h"

NS_ASSUME_NONNULL_BEGIN

@class BLMediaBrowserView;
/// 加载网络图片，缩略图和大图使用不同的url（支持gif图片）
@interface BLMediaWebItem : NSObject
// 加载图片的url
@property (nonatomic, copy) NSString *urlString;
//imageView的frame
@property (nonatomic, assign) CGRect frame;
//占位图的大小
@property (nonatomic, assign) CGSize placeholdSize;
//占位图片  default is [UIImage imageNamed:@"BLMediaLoading.png"]
@property (nonatomic , strong)UIImage *placeholdImage;

- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame;
- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdImage:(UIImage *)image;
- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdSize:(CGSize)size;
- (instancetype)initWithURLString:(NSString *)url frame:(CGRect)frame placeholdImage:(UIImage *)image placeholdSize:(CGSize)size;
@end

/// 加载本地图片（支持相册中的gif图片）
/*
 使用方式：
 NSMutableArray *items = [[NSMutableArray alloc]init];
 for (UIImageView *imageView in self.imageViews) {
       BLMediaLocalItem *item = [[BLMediaLocalItem alloc]initWithImage:imageView.image frame:imageView.frame];
       [items addObject:item];
   }
 [[BLMediaBrowserManager defaultManager] showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:self.view];
 */
@interface BLMediaLocalItem : NSObject
@property (nonatomic ,strong) UIImage *localImage;
@property (nonatomic ,assign) CGRect frame;
- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame;
@end


/*
 控件的基本结构
 |-------------------------BLMediaTapDetectingImageView------------------------| (最上层)
 
 |-------------------------BLMediaZoomScrollView------------------------|

 |-------------------------UICollectionViewCell------------------------|
 
 |-------------------------UICollectionView------------------------|
 
 |-------------------------BLMediaBrowseView------------------------|       (最下层)
 */
@interface BLMediaBrowserManager : NSObject

// 传入的urls
@property (nonatomic , strong, readonly) BLMediaUrlsMutableArray *urls;

// 传入的imageView的frames
@property (nonatomic , strong, readonly) BLMediaFramesMutableArray *frames;

//传入的本地图片
@property (nonatomic , strong, readonly) BLMediaImagesMutableArray *images;

// 关于联动的信息
@property (nonatomic , strong, readonly) NSMutableDictionary *linkageInfo;

// 用来展示图片的UI控件
@property (nonatomic , strong, readonly) BLMediaBrowserView *mediaBrowserView;

// 传入的imageView的共同父View
@property (nonatomic , weak, readonly) UIView *imageViewSuperView;

// 当前选中的页
@property (nonatomic , assign) NSInteger currentPage;

// 展示图片使用collectionView来提高效率
@property (nonatomic , weak) UICollectionView *currentCollectionView;

//当图片加载出现错误时候显示的图片  default is [UIImage imageNamed:@"BLMediaLoadError.jpg"]
@property (nonatomic , strong) UIImage *errorImage;

// 每张正在加载的图片的占位图
@property (nonatomic , copy ,readonly) UIImage *(^placeholdImageCallBackBlock)(NSIndexPath *indexPath);

// 每张正在加载的图片的占位图的大小
@property (nonatomic , copy ,readonly) CGSize (^placeholdImageSizeBlock)(UIImage *Image,NSIndexPath *indexpath);

/**
 开启这个选项后 在加载gif的时候 会大大的降低内存.与YYImage对gif的内存优化思路一样 default is NO
 每次BLMediaBrowser -> did dismiss(消失)的时候,BLMediaBrowserManager 会将 lowGifMemory 置为NO,
 故:如果需要修改该选项 需要每次弹出BLMediaBrowser的时候 将lowGifMemory 置为 YES;
 */
@property (nonatomic , assign)BOOL lowGifMemory;

// 当前图片浏览器正在展示的imageView
@property (nonatomic , strong)UIImageView *currentShowImageView;

/**
 是否需要预加载 default is YES
 每次BLMediaBrowser -> did dismiss(消失)的时候,BLMediaBrowserManager 会将 needPreloading 置为YES,
 故:如果需要修改该选项 需要每次弹出BLMediaBrowser的时候 将needPreloading 置为 NO;
 当使用
 */
@property (nonatomic , assign)BOOL needPreloading;

/**
 返回当前的一个单例(不完全单利)
 */
+ (instancetype)defaultManager;

/**
 展示本地图片
 @param items 传入本地的图片模型数组
 @param index 当前选中图片的下标
 @param superView 传入的控件的父View
 @return 返回当前对象
 */
- (instancetype)showImageWithLocalItems:(NSArray <BLMediaLocalItem *> *)items selectedIndex:(NSInteger)index fromImageViewSuperView:(UIView *)superView;

/**
 展示网络图片
 @param items 传入网络的图片模型数组
 @param index 当前选中图片的下标
 @param superView 传入的控件的父View
 @return 返回当前对象
 */
- (instancetype)showImageWithWebItems:(NSArray <BLMediaWebItem *> *)items selectedIndex:(NSInteger)index fromImageViewSuperView:(UIView *)superView;

/**
 展示网络图片
 上面的方法是对这个方法的进一步封装
 @param urls 传入的urls数组  字符串 或者 url都可以
 @param frames 传入的控件的frames
 @param index 当前选中图片的下标
 @param superView 传入的控件的父View
 @return 返回当前对象
 */
- (instancetype)showImageWithURLArray:(NSArray *)urls fromImageViewFrames:(NSArray *)frames selectedIndex:(NSInteger)index imageViewSuperView:(UIView *)superView;


#pragma mark - 回调
// 添加默认的长按控件
- (instancetype)addLongPressShowTitles:(NSArray <NSString *>*)titles;

// 默认长按控件的回调
- (instancetype)addTitleClickCallbackBlock:(void(^)(UIImage *image,NSIndexPath *indexPath,NSString *title))titleClickCallBackBlock;

// 添加自定义的长按控件
- (instancetype)addLongPressCustomViewBlock:(UIView *(^)(UIImage *image, NSIndexPath *indexPath))longPressBlock;

// 为每张图片添加占位图 defaut ->BLMediaLoading.png 如果通过BLMediaWebItem设置placeholdImage后,不需要实现
- (instancetype)addPlaceholdImageCallBackBlock:(UIImage *(^)(NSIndexPath *indexPath))placeholdImageCallBackBlock;

// 为每张占位图 设置大小 如果配置过BLMediaWebItem后,如果通过BLMediaWebItem设置placeholdSize后,不需要实现
- (instancetype)addPlaceholdImageSizeBlock:(CGSize (^)(UIImage *Image,NSIndexPath *indexpath))placeholdImageSizeBlock;

// 图片浏览器将要消失的回调
- (instancetype)addPhotoBrowserWillDismissBlock:(void(^)(void))dismissBlock;

// 图片浏览器彻底消失的回调
- (instancetype)addPhotoBrowserDidDismissBlock:(void(^)(void))dismissBlock;

- (instancetype)addCollectionViewLinkageStyle:(UICollectionViewScrollPosition)style cellReuseIdentifier:(NSString *)reuseIdentifier;
#pragma mark - get方法

- (NSArray<NSString *> *)currentTitles;

- (void (^)(UIImage *, NSIndexPath *, NSString *))titleClickBlock;

- (UIView *(^)(UIImage *,NSIndexPath *))longPressCustomViewBlock;
@end

NS_ASSUME_NONNULL_END
