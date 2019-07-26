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
@interface ViewController ()
@property (nonatomic,strong)NSArray *webpSource;
@property (nonatomic,strong)NSArray *svgaSouce;
@property (nonatomic,strong)QMAnimationPlayerView *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player = [[QMAnimationPlayerView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.player];
    self.svgaSouce = @[@"https://gift-resource.starmakerstudios.com/props/props_movie_201804161056401.svga",
                       @"https://gift-resource.starmakerstudios.com/props/props_movie_201804161056401.svga",
                       @"https://gift-resource.starmakerstudios.com/props/props_movie_201804161056401.svga",
                       @"https://gift-resource.starmakerstudios.com/props/props_movie_201804161056401.svga",
                       @"https://gift-resource.starmakerstudios.com/props/props_movie_201804110525341.svga",
                       @"https://gift-resource.starmakerstudios.com/props/props_movie_201804110525341.svga",
                       @"https://gift-resource.starmakerstudios.com/props/props_movie_201804110525341.svga",
                       @"https://gift-resource.starmakerstudios.com/props/props_movie_201804110525341.svga",
                       @"https://gift-resource.starmakerstudios.com/props/props_movie_201804270350461.svga",
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
                       ];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Source" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    NSLog(@"%@",bundle);
    NSArray *array =  [bundle pathsForResourcesOfType:@".webp" inDirectory:nil];
    NSLog(@"%@",array);
    self.webpSource = array;
}
- (IBAction)playMp4Animation:(id)sender {
}

- (IBAction)playWebpAnimation:(id)sender {
    [self startPlayerWebpAnimation:self.webpSource.firstObject];
}

- (IBAction)playSvgaAnimation:(id)sender {
    [self startSvgaAnimation:self.svgaSouce.firstObject];
}
- (void)startPlayerWebpAnimation:(NSString*)source{
    @weakify(self)
    static NSInteger playCount  = 0;
    [self.player playWithSource:source animationType:QMWebpGiftAnimationType extralParam:@{} completeHandler:^(BOOL complete, NSError * _Nullable error) {
        @strongify(self)
        if (++playCount< self.webpSource.count) {
            [self startPlayerWebpAnimation:self.webpSource[playCount]];
        }else{
            playCount= 0;
        }
    }];
}
- (void)startSvgaAnimation:(NSString*)source{
    static NSInteger playCount  = 0;
    @weakify(self)
    [self.player playWithSource:source animationType:QMSVGAGiftAnimationType extralParam:@{} completeHandler:^(BOOL complete, NSError * _Nullable error) {
        @strongify(self)
        if (++playCount< self.svgaSouce.count) {
            [self startSvgaAnimation:self.svgaSouce[playCount]];
        }else{
            playCount= 0;
        }
    }];
}



@end
