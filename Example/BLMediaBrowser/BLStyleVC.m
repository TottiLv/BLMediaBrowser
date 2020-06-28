//
//  BLStyleVC.m
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLStyleVC.h"

@interface BLStyleVC ()

@end

@implementation BLStyleVC

- (void)viewDidLoad {
    self.lagerURLStrings = @[
                             //大图
                             @"http://p7.pstatp.com/large/w960/5322000131e01b7a477d",
                             @"http://p7.pstatp.com/large/w960/5321000135125ebb938a",
                             @"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                             @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                             @"http://p2.pstatp.com/large/w960/4ecc00055b3ffcc909a9",
                             @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                             @"http://wx2.sinaimg.cn/large/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                             @"http://wx4.sinaimg.cn/large/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                             @"http://wx1.sinaimg.cn/large/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                             @"http://wx3.sinaimg.cn/large/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg"
                             ];
    self.thumbnailURLStrings = @[
                                 //小图
                                 @"http://p7.pstatp.com/list/s200/5322000131e01b7a477d",
                                 @"http://p7.pstatp.com/list/s200/5321000135125ebb938a",
                                 @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7orgqfj20i80ht15x.jpg",
                                 @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7pmnk7j20i70jidwo.jpg",
                                 @"http://p2.pstatp.com/list/s200/4ecc00055b3ffcc909a9",
                                 @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7rncxaj20ek0i74dv.jpg",
                                 @"http://wx2.sinaimg.cn/thumbnail/bfc243a3gy1febm7sdk4lj20ib0i714u.jpg",
                                 @"http://wx4.sinaimg.cn/thumbnail/bfc243a3gy1febm7tekewj20i20i4aoy.jpg",
                                 @"http://wx1.sinaimg.cn/thumbnail/bfc243a3gy1febm7n9eorj20i60hsann.jpg",
                                 @"http://wx3.sinaimg.cn/thumbnail/bfc243a3gy1febm7nzbz7j20ib0iek5j.jpg"
                                 ];
    [super viewDidLoad];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.model = self.models[indexPath.row];
    __weak typeof(cell) wcell = cell;
    [cell setCallBack:^(BLModel *cellModel, int tag) {
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (int i = 0 ; i < cellModel.urls.count; i++) {
            BLURLModel *urlModel = cellModel.urls[i];
            UIImageView *imageView = wcell.imageViews[i];
            BLMediaWebItem *item = [[BLMediaWebItem alloc]initWithURLString:urlModel.largeURLString frame:imageView.frame];
            item.placeholdImage = imageView.image;
            [items addObject:item];
        }
        
        [BLMediaBrowserManager.defaultManager showImageWithWebItems:items selectedIndex:tag fromImageViewSuperView:wcell.contentView].lowGifMemory = YES;
        
        [[[BLMediaBrowserManager.defaultManager addLongPressShowTitles:@[@"保存",@"转发",@"删除",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
            NSLog(@"%@",title);
        }]addPhotoBrowserWillDismissBlock:^{
            NSLog(@"即将销毁");
        }];
        
    }];
    return cell;
}
@end
