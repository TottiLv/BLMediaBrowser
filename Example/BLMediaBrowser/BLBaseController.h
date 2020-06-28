//
//  BLBaseController.h
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLCell.h"
#import "BLModel.h"
#import <BLMediaBrowser/BLMediaBrowserManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLBaseController : UITableViewController

@property (nonatomic , strong) NSMutableArray *models;

@property (nonatomic , strong)NSArray *lagerURLStrings;

@property (nonatomic , strong)NSArray *thumbnailURLStrings;

@end

NS_ASSUME_NONNULL_END
