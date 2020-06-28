//
//  BLLocalImageCollectionViewVC.m
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLLocalImageCollectionViewVC.h"
#import "BLWebImageCollectionViewVC.h"
#import <BLMediaBrowser/BLMediaBrowserManager.h>

static inline CGSize bl_screenSize(){
    return [UIScreen mainScreen].bounds.size;
}

@interface BLCellModel :NSObject
@property (nonatomic , strong)UIImage *image;
@property (nonatomic , assign)BOOL isAdd;

@end
@implementation BLCellModel
@end

@interface BLCollectionViewCell :UICollectionViewCell
@property (nonatomic , weak)UIImageView *imageView;
@end

@implementation BLCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        self.backgroundColor = [UIColor whiteColor];
        _imageView = imageView;
    }
    return self;
}

@end

@interface BLLocalImageCollectionViewVC ()<UICollectionViewDelegateFlowLayout,
                                UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate>
@property (nonatomic , weak)UICollectionView *collectionView;
@property (nonatomic , strong)NSMutableArray *datas;

@end

@implementation BLLocalImageCollectionViewVC

static NSString * const reuseIdentifier = @"Cell";

- (NSMutableArray *)datas {
    if (!_datas) {
        _datas = [[NSMutableArray alloc]init];
    }
    return _datas;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemSize = CGSizeMake(100, 100);
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,120,bl_screenSize().width, 110) collectionViewLayout:flowLayout];
        [self.view addSubview:collectionView];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor lightGrayColor];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    if ([UIDevice currentDevice].systemVersion.floatValue > 11.0) {
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.collectionView registerClass:[BLCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    BLCellModel *model = [[BLCellModel alloc]init];
    model.isAdd = YES;
    model.image = [UIImage imageNamed:@"bl_add"];
    [self.datas addObject:model];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"网络" style:UIBarButtonItemStylePlain target:self action:@selector(rightBtnClick)];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)rightBtnClick {
    BLWebImageCollectionViewVC *cvc = [[BLWebImageCollectionViewVC alloc]init];
    [self.navigationController pushViewController:cvc animated:YES];
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BLCellModel *model = (BLCellModel *)self.datas[indexPath.item];
    BLCollectionViewCell *cell = (BLCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = model.image;
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BLCellModel *model = (BLCellModel *)self.datas[indexPath.item];
    if (model.isAdd) {
        [self getImageFromIpc];
    }else {
        NSMutableArray *items = @[].mutableCopy;
        UICollectionView *cell = [collectionView cellForItemAtIndexPath:indexPath];// 这里不会为空
        for (BLCellModel *showModel in self.datas) {
            if (showModel.isAdd) continue;
            BLMediaLocalItem *item = [[BLMediaLocalItem alloc]initWithImage:showModel.image frame:cell.frame];
            [items addObject:item];
        }
        [[[[[BLMediaBrowserManager defaultManager] showImageWithLocalItems:items selectedIndex:indexPath.row fromImageViewSuperView:collectionView] addLongPressShowTitles:@[@"保存图片",@"删除",@"转发",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
            NSLog(@"%@",title);
        }]addCollectionViewLinkageStyle:UICollectionViewScrollPositionCenteredHorizontally cellReuseIdentifier:reuseIdentifier];
    }
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
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        BLCellModel *model = [[BLCellModel alloc]init];
        model.image = image;
        [self.datas insertObject:model atIndex:0];
        [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
    }];
    
}


@end
