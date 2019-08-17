//
//  QMGiftSourceDownloaderManager.m
//  GiftPlayer
//
//  Created by yuanpinghua on 2019/7/31.
//  Copyright © 2019 yuanpinghua. All rights reserved.
//

#import "QMGiftZipSourceManager.h"
#import <AFNetworking.h>
#import "FCFileManager.h"
#import <YYModel.h>
#import <SSZipArchive.h>
#import "CommonMacro.h"

QMGiftContextOption const QMGiftContextOptionFilePath = @"path";///<礼物本地地址
QMGiftContextOption const QMGiftContextOptionShowSender = @"showSender";///<礼物是否展示发送者 其返回值是一个@(NO)/@(YES);
//礼物根路径
static  NSString  *giftZipDir = @"GiftZip";
static  NSString  *giftDir = @"Gift";
static  NSString  *giftRootDir = @"GiftSource";

@interface QMGiftZipSourceManager()
@property (nonatomic,strong) AFURLSessionManager *sessionManager;
@property (nonatomic,strong) NSMutableArray<NSString*> * downloadSources;
@property (nonatomic,strong) NSMutableDictionary<NSString*,NSNumber*> *retryDownloadSource;
@end


@implementation QMGiftZipSourceManager
+ (instancetype)sharedInstance{
    static QMGiftZipSourceManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [QMGiftZipSourceManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //默认配置
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"QMGiftSourceBgSessionIdentifier"];
        //AFN3.0+基于封住URLSession的句柄
        self.sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        self.downloadSources  = [NSMutableArray array];
    }
    return self;
}
- (void)downloadGiftzipSource:(NSString *)zipSource retrySource:(NSString*)retrySource{
    if (NULLString(zipSource)) {
        return;
    }
    NSString *zipPath = [self localPathForRemoteSource:zipSource];
    //本地存在，或当前有相同地资源正在下载
    if ([self existSourceInLocal:zipSource]||[self.downloadSources containsObject:zipSource]) {
        return;
    }
    if (![self.downloadSources containsObject:zipSource]) {
        [self.downloadSources  addObject:zipSource];
    }
    if (!NULLString(retrySource)) {
        ///如果有备用下载资源，且在重试下载数据中不存在该数据，则标识该备用资源未下载，在后续原资源下载失败时使用备用资源进行下载
        if ([self.retryDownloadSource.allKeys containsObject:retrySource]) {
            [self.retryDownloadSource setObject:@(0) forKey:retrySource];///<当前资源未进行失败重试下载过
        }
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:zipSource]];
    @weakify(self)
    [[self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        // 返回保路径
        return [NSURL fileURLWithPath:zipPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        @strongify(self)
        //下载完成
        [self.downloadSources removeObject:zipSource];
        if (error) {
            NSLog(@"%@:下载失败 errror :%@",zipSource,error.localizedDescription);
            if (!NULLString(retrySource)) {
                ///备用下载资源链接是否下载过，若没有下载过，则用备用资源进行下载
                if (![[self.retryDownloadSource objectForKey:retrySource]boolValue]) {
                    [self.retryDownloadSource setObject:@(1) forKey:retrySource];
                    [self downloadGiftzipSource:retrySource retrySource:nil];
                }
            }
        }else{
            NSLog(@"%@ complete",response.URL.path);
            NSString *rootpath = [[self giftRootPath] stringByAppendingPathComponent:giftDir];
            if (![FCFileManager existsItemAtPath:rootpath]) {
                [FCFileManager createDirectoriesForPath:rootpath];
            }
            ///下载的是zip文件，则进行解压
            if (filePath && [filePath.pathExtension.lowercaseString isEqualToString:@"zip"]) {
                rootpath =  [rootpath stringByAppendingPathComponent:[filePath.lastPathComponent stringByDeletingPathExtension]];
                [self releaseZipFilesWithUnzipFileAtPath:filePath.path Destination:rootpath];
            }else{
                //不是zip资源，则直接拷白贝到资源目录下
                //这里要特别主意，目标文件路径一定要以文件名结尾，而不要以文件夹结尾
                rootpath = [rootpath stringByAppendingPathComponent:filePath.lastPathComponent];
                [FCFileManager moveItemAtPath:filePath.path toPath:rootpath];
            }
        }
    }] resume];
}
-(BOOL)existSourceInLocal:(NSString*)remoteSource{
    NSString *rootpath = [[self giftRootPath] stringByAppendingPathComponent:giftDir];
    if (![FCFileManager existsItemAtPath:rootpath]) {
        [FCFileManager createDirectoriesForPath:rootpath];
    }
    NSString *sourceName = remoteSource.lastPathComponent;
    NSString *pathExtension = remoteSource.pathExtension.lowercaseString;
    //如果传来的不是找zip资源，则在资源目录下找相同文件名的文件，并返回
    if (![pathExtension isEqualToString:@"zip"]) {
        NSString *filePath = [rootpath stringByAppendingPathComponent:sourceName];
        if ([FCFileManager existsItemAtPath:filePath]) {
            return YES;
        }
    }else{
        rootpath =  [rootpath stringByAppendingPathComponent:[remoteSource.lastPathComponent stringByDeletingPathExtension]];
        if (![FCFileManager existsItemAtPath:rootpath]) {
            //文件不存在，尝试从服务端下载，方便下次使用
            return NO;
        }
        NSString *configPath = [rootpath stringByAppendingPathComponent:@"config.json"];
        
        if (![FCFileManager existsItemAtPath:configPath]) {
            return NO;
        }
        NSString * configContent = [NSString stringWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *dic = [configContent yy_modelToJSONObject];
        NSDictionary *p =  dic [@"p"];
        NSString *filepath =  p[QMGiftContextOptionFilePath];
        NSString *sourePath = [rootpath stringByAppendingPathComponent:filepath];
        //确认资源是否存在
        if ([FCFileManager existsItemAtPath:sourePath]) {
            return YES;
        }
    }
    return NO;
}

- (void)releaseZipFilesWithUnzipFileAtPath:(NSString *)zipPath Destination:(NSString *)unzipPath{
    NSError *error;
    if ([SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath overwrite:YES password:nil error:&error delegate:nil]) {
        NSLog(@"解压成功 unzipPath = %@",unzipPath);
    }
    //移除压缩包
    [FCFileManager removeItemAtPath:zipPath];
}
-(NSString*)localPathForRemoteSource:(NSString*)source{
    //检测是否存在根目录/没有则创建
    NSString * zipDir = [[self giftRootPath]stringByAppendingPathComponent:giftZipDir];
    if (![FCFileManager existsItemAtPath:zipDir]) {
        [FCFileManager createDirectoriesForPath:zipDir];
    }
    NSString * fileName = [source lastPathComponent];
    
    NSString * zipPath = [zipDir stringByAppendingPathComponent:fileName];
    return zipPath;
}

-(NSString*)giftRootPath{
    return [FCFileManager pathForDocumentsDirectoryWithPath:giftRootDir];
}

/**
 *通过礼物资源地址返回本地下载好的礼特资源信息
 */
-(NSDictionary*)cacheGiftInfoForSource:(NSString*)source{
    if (NULLString(source)) {
        return nil;
    }
    NSString *rootpath = [[self giftRootPath] stringByAppendingPathComponent:giftDir];
    if (![FCFileManager existsItemAtPath:rootpath]) {
        [FCFileManager createDirectoriesForPath:rootpath];
    }
    NSString *sourceName = source.lastPathComponent;
    NSString *pathExtension = source.pathExtension.lowercaseString;
    //如果传来的不是找zip资源，则在资源目录下找相同文件名的文件，并返回
    if (![pathExtension isEqualToString:@"zip"]) {
        NSString *filePath = [rootpath stringByAppendingPathComponent:sourceName];
        if (![FCFileManager existsItemAtPath:filePath]) {
            //文件不存在，尝试从服务端下载，方便下次使用
            [self downloadGiftzipSource:source retrySource:nil];
            return nil;
        }
        return @{@"path":filePath};
    }else{
        rootpath =  [rootpath stringByAppendingPathComponent:[source.lastPathComponent stringByDeletingPathExtension]];
        if (![FCFileManager existsItemAtPath:rootpath]) {
            //文件不存在，尝试从服务端下载，方便下次使用
            [self downloadGiftzipSource:source retrySource:nil];
            return nil;
        }
        NSString *configPath = [rootpath stringByAppendingPathComponent:@"config.json"];
        
        if (![FCFileManager existsItemAtPath:configPath]) {
            return nil;
        }
        NSString * configContent = [NSString stringWithContentsOfFile:configPath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *dic = [configContent yy_modelToJSONObject];
        NSDictionary *p =  dic [@"p"];
        NSString *filepath =  p[QMGiftContextOptionFilePath];
        BOOL showSender = [p[QMGiftContextOptionShowSender] boolValue];
        NSString *sourePath = [rootpath stringByAppendingPathComponent:filepath];
        //确认资源是否存在
        if (![FCFileManager existsItemAtPath:sourePath]) {
            return nil;
        }
        return @{QMGiftContextOptionFilePath:sourePath,
                 QMGiftContextOptionShowSender :@(showSender),
                 };
    }
}
- (NSUInteger)totalSize {
    NSUInteger size = 0;
    NSString *rootpath = [[self giftRootPath] stringByAppendingPathComponent:giftDir];
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:rootpath];
    for (NSString *fileName in fileEnumerator) {
        NSString *filePath = [rootpath stringByAppendingPathComponent:fileName];
        NSDictionary<NSString *, id> *attrs = [fileManager attributesOfItemAtPath:filePath error:nil];
        size += [attrs fileSize];
    }
    return size;
}
-(void)cleanDiskCache{
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    NSString *rootpath = [[self giftRootPath] stringByAppendingPathComponent:giftDir];
    [fileManager removeItemAtPath:rootpath error:nil];
    [fileManager createDirectoryAtPath:rootpath
                withIntermediateDirectories:YES
                                 attributes:nil
                                      error:NULL];
}
@end

