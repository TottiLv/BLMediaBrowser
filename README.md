# BLMediaBrowser
说明：
 点击展示大图效果，支持：单击、双击、拖拽等事件
下载地址：https://github.com/TottiLv/BLMediaBrowser.git

### BLMediaBrowserManager
## 下载demo，run，然后可以看效果

```
pod 'BLMediaBrowser', :path => '../'
```

#### Creating a Local Task

```objective-c
for (BLCellModel *showModel in self.datas) {
    if (showModel.isAdd) continue;
    BLMediaLocalItem *item = [[BLMediaLocalItem alloc]initWithImage:showModel.image frame:cell.frame];
    [items addObject:item];
}

[[[[[BLMediaBrowserManager defaultManager] showImageWithLocalItems:items selectedIndex:indexPath.row fromImageViewSuperView:collectionView] addLongPressShowTitles:@[@"保存图片",@"删除",@"转发",@"取消"]] addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
    NSLog(@"%@",title);
}] addCollectionViewLinkageStyle:UICollectionViewScrollPositionCenteredHorizontally cellReuseIdentifier:reuseIdentifier];
```

#### Creating a Web Task
```objective-c
for (int i = 0; i < self.lagerURLStrings.count; i++ ) {
    BLWebCollectionViewCell *cell = ( BLWebCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
    BLMediaWebItem *item = [[BLMediaWebItem alloc]initWithURLString:self.lagerURLStrings[i] frame:cell.frame];
    item.placeholdImage = [UIImage imageNamed:@"placehold.jpeg"];
    [items addObject:item];
}
[[[[[BLMediaBrowserManager defaultManager] showImageWithWebItems:items selectedIndex:indexPath.row fromImageViewSuperView:collectionView] addCollectionViewLinkageStyle:UICollectionViewScrollPositionCenteredHorizontally cellReuseIdentifier:reuseIdentifier]addLongPressShowTitles:@[@"保存图片",@"删除",@"转发",@"取消"]]addTitleClickCallbackBlock:^(UIImage *image, NSIndexPath *indexPath, NSString *title) {
    NSLog(@"%@",title);
}].lowGifMemory = YES;
//是否支持预加载
[BLMediaBrowserManager defaultManager].needPreloading = NO;
```


