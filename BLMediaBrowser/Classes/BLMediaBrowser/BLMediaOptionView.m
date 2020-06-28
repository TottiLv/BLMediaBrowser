//
//  BLMediaOptionView.m
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLMediaOptionView.h"
#import "BLMediaBrowserConst.h"
#import "UIView+BLMediaViewFrame.h"
#import "BLMediaBrowserManager.h"

static NSString * ID = @"blm.optionView";

static CGFloat cellHeight = 50;

static inline BLMediaBrowserManager * photoBrowseManager() {
    return [BLMediaBrowserManager defaultManager];
}
static inline CGFloat getTableViewHeight() {
    return [photoBrowseManager() currentTitles].count * cellHeight;
}

@interface BLMediaOptionView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , weak)UITableView *tableView;

@end


@implementation BLMediaOptionView

- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, BL_MEDIA_SCREEN_HEIGHT, BL_MEDIA_SCREEN_WIDTH,getTableViewHeight() + BL_MEDIA_BOTTOM_MARGIN)];
        tableView.bottom = BL_MEDIA_IS_IPHONE ? self.bottom - BL_MEDIA_BOTTOM_MARGIN_IPHONEX : self.bottom;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.bounces = NO;
        [self addSubview:tableView];
        _tableView = tableView;
    }
    return _tableView;
}

+ (instancetype)showOptionView {
    BLMediaOptionView *view = [[self alloc]init];
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    CGFloat tableViewHeight = getTableViewHeight();
    [UIView animateWithDuration:0.25 animations:^{
        view.tableView.top = BL_MEDIA_SCREEN_HEIGHT - tableViewHeight - BL_MEDIA_BOTTOM_MARGIN;
    }];
    return view;
}

+ (instancetype)showOptionViewWithCurrentCellImage:(UIImage *)image {
    BLMediaOptionView *view = [self showOptionView];
    view.image = image;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        self.frame = [UIScreen mainScreen].bounds;
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self dismissOptionView];
}

#pragma mark - bgView的点击事件

- (void)dismissOptionView {
    weak_self;
    [UIView animateWithDuration:0.25 animations:^{
        wself.tableView.top = BL_MEDIA_SCREEN_HEIGHT;
    }completion:^(BOOL finished) {
        [wself removeFromSuperview];
    }];
}

#pragma mark - tableView数据源

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [photoBrowseManager() currentTitles].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.textLabel.text = [photoBrowseManager() currentTitles][indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.separatorInset = UIEdgeInsetsMake(0, 15, 0, 15);
    }
    return cell;
}
#pragma mark - tableView的代理

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = photoBrowseManager().currentTitles[indexPath.row];
    if (photoBrowseManager().titleClickBlock) {
        photoBrowseManager().titleClickBlock(self.image,indexPath,title);;
    }
    [self dismissOptionView];
}

@end
