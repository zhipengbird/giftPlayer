//
//  ViewController.m
//  GiftPlayer
//
//  Created by yuanpinghua on 2019/7/26.
//  Copyright © 2019 yuanpinghua. All rights reserved.
//

#import "ViewController.h"
#import "QMAnimationPlayerView.h"
#import "CommonMacro.h"
#import "QMGiftZipSourceManager.h"
@interface ViewController ()
@property (nonatomic,strong)NSArray *webpSource;
@property (nonatomic,strong)NSArray *svgaSouce;
@property (nonatomic,strong)QMAnimationPlayerView *player;
@property (nonatomic,strong)QMGiftZipSourceManager *downloaderManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.downloaderManager = [QMGiftZipSourceManager sharedInstance];
    self.player = [[QMAnimationPlayerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.player];
    self.svgaSouce =    @[
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180416105640.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180411052534.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180427035046.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180427034951.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180418075141.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180706094654.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20181126120739.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180727024042.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180817063425.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180817021412.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180817021525.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180824085019.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180824085110.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20180824085146.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20181022090247.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20181108081333.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190124040549.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190201023843.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190404125444.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190409025303.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190416062930.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190415034325.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190416063239.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190416063406.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190416063455.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190416063554.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190416063729.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190529030449.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190722131008.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190723072808.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190722131132.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190722131221.svga",
        @"https://static.starmakerstudios.com/production/statics/horse/horse_movie_20190723090125.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804161056401.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804161056401.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804161056401.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804161056401.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804110525341.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804110525341.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804110525341.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804110525341.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270350461.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270350461.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270350461.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270350461.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270349511.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270349511.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270349511.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270349511.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20180707022251.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20180707022328.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20180707022352.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20180707022416.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20180719043610.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181017123759.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181022093513.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181022093607.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181022093650.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181022093709.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181024090645.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181024090712.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181031031221.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181031033738.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181031033753.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181031072049.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181031073111.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190315095414.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181206062226.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181116094701.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181119125419.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181213034801.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181213033958.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181213034041.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181213034113.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181206062157.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181206062135.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181206062104.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181206062031.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20181212073354.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190109040439.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190124041311.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190201023932.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190331045032.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190331052444.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190404125535.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190409025400.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190409033153.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190410070347.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190410070458.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190410070537.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190410080310.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190410080423.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190410080511.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190410080537.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190411085538.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190411085553.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190411085609.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190411085627.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190413085222.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190413091739.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416063850.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416063945.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416064030.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416064131.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416064205.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416064237.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416064318.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416064853.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416064925.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416065436.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416065504.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416065534.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416065606.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416065633.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416065701.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081139.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081222.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081356.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081417.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081435.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081529.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081604.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081619.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081716.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081750.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081808.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081909.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081933.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416081959.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416082039.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416082101.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190416082121.svga",
        @"https://gift-resource.starmakerstudios.com/props/props_bag_20190529030722.svga",
    ];
    
    for (NSString *path  in self.svgaSouce) {
        [self.downloaderManager downloadGiftzipSource:path retrySource:nil];
    }
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Source" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSLog(@"%@",bundle);
    NSArray *array =  [bundle pathsForResourcesOfType:@".webp" inDirectory:nil];
    NSLog(@"%@",array);
    self.webpSource = array;
    //    [SDWebImagePrefetcher sharedImagePrefetcher] pref
}
- (IBAction)playMp4Animation:(id)sender {
    self.downloaderManager = [QMGiftZipSourceManager sharedInstance];
    NSString *sourcePath = [[NSBundle mainBundle]pathForResource:@"source.txt" ofType:nil];
    NSString *giftSource =[NSString stringWithContentsOfFile:sourcePath encoding:NSUTF8StringEncoding error:nil];
    if (NULLString(giftSource)) {
        return;
    }
    NSArray *sourceList = [giftSource componentsSeparatedByString:@"\n"];
    NSSet *set = [NSSet setWithArray:sourceList];
    for (NSString *url in set.allObjects) {
        [self.downloaderManager downloadGiftzipSource:url retrySource:nil];
    }
    //    for (NSString *url in sourceList) {
    //       NSDictionary *info =   [self.downloaderManager cacheGiftInfoForSource:url];
    //        NSLog(@"%@",info);
    //    }
}

- (IBAction)playWebpAnimation:(id)sender {
    [self startPlayerWebpAnimation:self.webpSource.firstObject];
}

- (IBAction)playSvgaAnimation:(id)sender {
    NSString *source = self.svgaSouce[0];
    NSString * path =  [self.downloaderManager cacheGiftInfoForSource:source][@"path"];
    if (path) {
        [self startSvgaAnimation:path];
    }
}
- (void)startPlayerWebpAnimation:(NSString*)source{
    @weakify(self)
    static NSInteger playCount  = 0;
    [self.player playWithSource:source extraParams:@{} finishBlock:^(BOOL complete, NSError * _Nullable error) {
        @strongify(self)
        if (++playCount < self.webpSource.count) {
            [self startPlayerWebpAnimation:self.webpSource[playCount]];
        }else{
            playCount= 0;
        }
    }];
}
- (void)startSvgaAnimation:(NSString*)source{
    static NSInteger playCount  = 0;
    @weakify(self)
    [ self.player playWithSource:source extraParams:@{} finishBlock:^(BOOL complete, NSError * _Nullable error) {
        @strongify(self)
        if (++playCount< self.svgaSouce.count) {
            if ((playCount +1) == self.svgaSouce.count  ) {
                playCount = 0;
            }
            NSString *source = self.svgaSouce[playCount];
            NSString * path =  [self.downloaderManager cacheGiftInfoForSource:source][QMGiftContextOptionFilePath];
            if (!NULLString(path)) {
                [self startSvgaAnimation:path];
            }
        }
    }];
    
}

@end
