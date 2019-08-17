//
//  QMGiftSourceDownloaderManager.h
//  GiftPlayer
//
//  Created by yuanpinghua on 2019/7/31.
//  Copyright © 2019 yuanpinghua. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NSString * QMGiftContextOption NS_EXTENSIBLE_STRING_ENUM;
extern QMGiftContextOption _Nonnull const QMGiftContextOptionFilePath;///<礼物本地地址
extern QMGiftContextOption _Nonnull const QMGiftContextOptionShowSender;///<礼物是否展示发送者 其返回值是一个@(NO)/@(YES);
/**
 大礼物资源下载/查找管理
 */
@interface QMGiftZipSourceManager : NSObject

+ (instancetype)sharedInstance;

/**
 下载礼物资源
 优先使用zipSource进行下载，若该资源下载失败，使用备用资源再次尝试下载
 ps:确保zip资源不为空，若为空则不再下载
 @param zipSource 下载的资源路径
 @param retrySource 备用下载资源
 */
- (void)downloadGiftzipSource:(NSString *)zipSource retrySource:(NSString* _Nullable)retrySource;

/**
 *通过礼物资源地址返回本地下载好的礼特资源信息
 *如果不存在返回结果为nil,反之返回
 {
 QMGiftContextOptionFilePath:filePath,
 QMGiftContextOptionShowSender:@(Yes)
 }字典信息
 */
-(NSDictionary<QMGiftContextOption,id>* _Nullable)cacheGiftInfoForSource:(NSString*)source;

/**
 缓存文件总大小

 @return 文件大小
 */
- (NSUInteger)totalSize;

/**
 清理礼物缓存
 */
-(void)cleanDiskCache;
@end

NS_ASSUME_NONNULL_END
