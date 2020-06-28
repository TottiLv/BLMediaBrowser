//
//  BLCell.m
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation BLCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUpUI];
    }
    return self;
}
- (NSMutableArray *)imageViews {
    if (!_imageViews) {
        _imageViews = [[NSMutableArray alloc]init];
    }
    return _imageViews;
}

- (void)setUpUI {
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.clipsToBounds = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewClick:)];
        [imageView addGestureRecognizer:tap];
        [self.imageViews addObject:imageView];
        [self.contentView addSubview:imageView];
    }
}

- (void)setModel:(BLModel *)model {
    _model = model;
    BL_WEAK_SELF;
    [self.imageViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = (UIImageView *)obj;
        imageView.hidden = YES;
        imageView.image = nil;
    }];
    [model.frames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageV = wself.imageViews[idx];
        imageV.hidden = NO;
        imageV.frame = [model.frames[idx] CGRectValue];
        [imageV sd_setImageWithURL:[NSURL URLWithString:model.urls[idx].thumbnailURLString]];
    }];
}



- (void)imageViewClick:(UITapGestureRecognizer *)tap {
    if (_callBack) {
        _callBack(self.model,tap.view.tag);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{return;}
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{return;}
@end

