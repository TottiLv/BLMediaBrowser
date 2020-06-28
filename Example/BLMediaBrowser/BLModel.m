//
//  BLModel.m
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import "BLModel.h"

static CGFloat cell_space = 10;

@implementation BLURLModel

@end

@implementation BLModel

- (NSMutableArray<BLURLModel *> *)urls {
    if (!_urls) {
        _urls = [[NSMutableArray alloc]init];
    }
    return _urls;
}
- (NSMutableArray *)frames {
    if (!_frames) {
        _frames = [[NSMutableArray alloc]init];
    }
    return _frames;
}


- (void)loadFrames {
    _height = 0;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    switch (self.urls.count) {
        case 1:
        {
            CGRect frame = CGRectMake(0, 0, 200, 150);
            [self.frames addObject: [NSValue valueWithCGRect:frame]];
            _height = frame.size.height;
        }
            break;
        case 2:
        {
            CGFloat width = (screenWidth - cell_space)/2.0;
            CGRect frameLeft = CGRectMake(0, 0, width, width);
            CGRect frameRight = CGRectMake(CGRectGetMaxX(frameLeft) + cell_space, 0, width, width);
            [self.frames addObject: [NSValue valueWithCGRect:frameLeft]];
            [self.frames addObject: [NSValue valueWithCGRect:frameRight]];
            _height = frameLeft.size.width;
        }
            break;
            
        default:
        {
            int column = self.urls.count == 4 ? 2 : 3;
            CGFloat itemWidth = (screenWidth - 2 * cell_space) / 3;
            CGFloat itemHeight = itemWidth;
            for (int i = 0; i < self.urls.count; i++) {
                CGFloat x = (i % column) * (cell_space + itemWidth) ;
                CGFloat y = (i / column) * (cell_space + itemHeight);
                CGRect frame = CGRectMake(x, y, itemWidth, itemHeight);
                [self.frames addObject:[NSValue valueWithCGRect:frame]];
            }
            _height = CGRectGetMaxY([self.frames.lastObject CGRectValue]);
        }
            break;
    }
}

@end
