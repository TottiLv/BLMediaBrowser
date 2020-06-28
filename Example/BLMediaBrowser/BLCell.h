//
//  BLCell.h
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLModel.h"

NS_ASSUME_NONNULL_BEGIN


#define BL_WEAK_SELF __weak typeof(self)wself = self

static  NSString *ID = @"bl.cell";
@interface BLCell : UITableViewCell

@property (nonatomic , strong) NSMutableArray *imageViews;
@property (nonatomic , strong) NSMutableArray *frames;
@property (nonatomic , strong) BLModel *model;
@property (nonatomic , copy)void (^callBack)(BLModel *cellModel, int tag);

@end

NS_ASSUME_NONNULL_END
