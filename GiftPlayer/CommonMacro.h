//
//  CommonMacro.h
//  QMAnimationPlayerTest
//
//  Created by yuanpinghua on 2019/7/22.
//  Copyright © 2019 yuanpinghua. All rights reserved.
//

#ifndef CommonMacro_h
#define CommonMacro_h
#define weakify(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define strongify(o) autoreleasepool{} __strong typeof(o) o = o##Weak;
//string是否为空、空对象。。。
#define NULLString(string) ((![string isKindOfClass:[NSString class]]) || [string isEqualToString:@""] || (string == nil) || [string isEqualToString:@""] || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0 || [string isEqualToString:@"(null)"] || [string isEqualToString:@"<null>"])
#define mRGBToAlpColor(rgb, alp) [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16)) / 255.0 green:((float)((rgb & 0xFF00) >> 8)) / 255.0 blue:((float)(rgb & 0xFF)) / 255.0 alpha:alp]

/** 屏幕高度 */
#define mScreenHeight [UIScreen mainScreen].bounds.size.height
#define SCREEN_HEIGH [[UIScreen mainScreen] bounds].size.height
#import  <Masonry.h>
#import <SDWebImage.h>
#import <SDWebImageWebPCoder.h>

#endif /* CommonMacro_h */
