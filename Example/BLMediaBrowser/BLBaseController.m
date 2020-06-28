//
//  BLBaseController.m
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLBaseController.h"

@interface BLBaseController ()

@end

@implementation BLBaseController

- (void)dealloc {
    NSLog(@"%@ 销毁了",NSStringFromClass([self class]));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _models = @[].mutableCopy;
    [self.tableView registerClass:[BLCell class] forCellReuseIdentifier:ID];
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableArray *items = [[NSMutableArray alloc]init];
        for (int i = 0; i < self.lagerURLStrings.count; i++) {
            BLURLModel *model = [BLURLModel new];
            model.thumbnailURLString = self.thumbnailURLStrings[i];
            model.largeURLString = self.lagerURLStrings[i];
            [items addObject:model];
        }
        
        for (int i = 0; i < 20; i++) {
            int count = arc4random() % 9;// [0,9)
            BLModel *model = [BLModel new];
            for (int i = 0; i < count ; i++) {
                int x = arc4random() % self.lagerURLStrings.count;
                BLURLModel *urlModel = items[x];
                BLURLModel *newModel = [[BLURLModel alloc]init];
                newModel.thumbnailURLString = urlModel.thumbnailURLString;
                newModel.largeURLString = urlModel.largeURLString;
                [model.urls addObject:newModel];
            }
            [model loadFrames];
            [self.models addObject:model];
        }
        
        
        // 确保第一组数 含有9张图片
        BLModel *model = self.models.firstObject;
        [model.urls removeAllObjects];
        [model.frames removeAllObjects];
        for (int i = 0; i < 9; i++) {
            BLURLModel *newModel = [[BLURLModel alloc]init];
            BLURLModel *urlModel = items[i];
            newModel.thumbnailURLString = urlModel.thumbnailURLString;
            newModel.largeURLString = urlModel.largeURLString;
            [model.urls addObject:newModel];
        }
        [model loadFrames];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tableView.delegate = self;
            self.tableView.dataSource = self;
            [self.tableView reloadData];
        });
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.models.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BLCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    cell.model = self.models[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BLModel *model = self.models[indexPath.row];
    return model.height + 50;
}

@end
