//
//  BLModel.h
//  BLMediaBrowser_Example
//
//  Created by lvjianxiong on 2020/6/27.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BLURLModel : NSObject

@property (nonatomic , copy)NSString *thumbnailURLString;
@property (nonatomic , copy)NSString *largeURLString;

@end

@interface BLModel : NSObject

@property (nonatomic , strong)NSMutableArray <BLURLModel *>*urls;
@property (nonatomic , strong)NSMutableArray *frames;
@property (nonatomic , assign)CGFloat height;

- (void)loadFrames;

@end

NS_ASSUME_NONNULL_END
