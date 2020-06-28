//
//  BLMediaBrowserConst.h
//  BLMeidaBrowser
//
//  Created by lvjianxiong on 2020/5/20.
//  Copyright © 2020 wolf_childer@163.com. All rights reserved.
//

#ifndef BLMediaBrowserConst_h
#define BLMediaBrowserConst_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSMutableArray<NSURL *> BLMediaUrlsMutableArray;
typedef NSMutableArray <NSValue *> BLMediaFramesMutableArray;
typedef NSMutableArray<UIImage *> BLMediaImagesMutableArray;

#define  weak_self  __weak typeof(self) wself = self

#ifndef BL_MEDIA_SCREEN_WIDTH

#define BL_MEDIA_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

#endif

#ifndef BL_MEDIA_SCREEN_HEIGHT

#define BL_MEDIA_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#endif


#define BL_MEDIA_IS_IPHONE [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone

#define BL_MEDIA_IS_IPHONEX (BL_MEDIA_SCREEN_HEIGHT == 812 && BL_MEDIA_IS_IPHONE)

#define BL_MEDIA_BOTTOM_MARGIN_IPHONEX 34

#define BL_MEDIA_BOTTOM_MARGIN (BL_MEDIA_IS_IPHONEX ? 34 : 0)


//UIKIT_EXTERN NSString * const BLMediaImageViewWillDismissNot;
//UIKIT_EXTERN NSString * const BLMediaImageViewDidDismissNot;
//UIKIT_EXTERN NSString * const BLMediaGifImageDownloadFinishedNot;

//UIKIT_EXTERN NSString * const BLMediaLinkageInfoStyleKey;
//UIKIT_EXTERN NSString * const BLMediaLinkageInfoReuseIdentifierKey;

#endif /* BLMediaBrowserConst_h */
