//
//  QMVideoView.m
//  QMAnimationPlayerTest
//
//  Created by yuanpinghua on 2019/7/18.
//  Copyright © 2019 yuanpinghua. All rights reserved.
//

#import "QMAlphaVideoView.h"
#import "GPUImage.h"
#import "QMAlphaVideoFilter.h"
#import "CommonMacro.h"
@interface QMAlphaVideoView ()
@property (nonatomic,strong) GPUImageMovie *movie;
@property (nonatomic,strong) QMAlphaVideoFilter *filter;
@property (nonatomic,strong) GPUImageView *playerView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, copy) QMAlphaVideoPlayerDidFinish completeHandler;
@end

@implementation QMAlphaVideoView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //前后台切换处理
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
//       AVAudioSessionCategoryPlayAndRecord 在录音的同时播放其他声音，当锁屏或按静音时不会停止
//        可用于听筒播放，比如微信语音消息听筒播放
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker
                       error:nil];
    }
    return self;
}

-(void)playVideoWithSource:(NSURL *)sourceURL completeHandler:(nonnull QMAlphaVideoPlayerDidFinish)completeHandler{
    //如果资源为空，直接返回
    //如果应用程序当前不处理活跃状态，也直接返回，应GPUMovie不能在应用非活跃状态下渲染
    if (!sourceURL||[UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        if (completeHandler) {
            completeHandler(NO,nil);
        }
        return;
    }
    self.completeHandler = completeHandler;
    self.opaque = YES;
    if (!self.playerView) {
        self.playerView = [GPUImageView new];
        [self addSubview:self.playerView];
        [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        self.playerView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    }
    ///对播放的视频进行缓存
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:sourceURL];
    if (!self.player) {
        ///进行多次复用player
        self.player = [AVPlayer new];
    }
    if (self.player.currentItem) {
        ///！！！这里必须要取消当前的playerItem的监听，不然在调用replaceCurrentItemWithPlayerItem：后会立即收到一个播放结束的通知
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    
    _filter = [QMAlphaVideoFilter new];
    _movie  = [[GPUImageMovie  alloc] initWithPlayerItem:playerItem];
    _movie.playAtActualSpeed = true;
    [_movie addTarget:_filter];
    [_movie startProcessing];
    
    [_filter addTarget:self.playerView];
    //要设置GPUimageView的背景色，不然会是黑色背景
    self.playerView.backgroundColor = UIColor.clearColor;
    
    [self play];
}

#pragma mark - 通知处理
-(void)didFinishPlaying:(NSNotification*)notification{
    if (_player.currentItem == notification.object) {
        _isPlaying  = false;
        [self.movie endProcessing];
        [self.movie removeAllTargets];
        [self.filter removeAllTargets];
        self.filter = nil;
        self.movie = nil;
        [self.playerView removeFromSuperview];
        self.playerView = nil;
        ///去除通知监听
        [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
        [self.player replaceCurrentItemWithPlayerItem:nil];
        if (self.completeHandler) {
            self.completeHandler(YES, nil);
        }
    }
}

-(void)applicationDidEnterBackground:(NSNotification*)notification{
    [self stop];
}
#pragma mark - 控制接口
-(void)play{
    if (!self.isPlaying) {
        [_player play];
        _isPlaying = YES;
    }
}
-(void)pause{
    if (self.isPlaying) {
        [self.player pause];
        _isPlaying = NO;
    }
}
-(void)resume{
    //不在播放状态，且当前currentItem不为空
    if (!self.isPlaying && self.player.currentItem) {
        [self.player play];
        _isPlaying = YES;
    }
}
-(void)stop{
    //动画进入后台时，我们会手动调用endProcessing来结束动画，并回调用给外部，
    //因调用endProcessing后，gpuImageView会保留最后一帧的画面，所以需要将playerView从视图中子移除并置空，下在使用时再次创建
    [self.movie endProcessing];
    [self.movie removeAllTargets];
    [self.filter removeAllTargets];
    self.filter = nil;
    self.movie = nil;
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    ///去除播放通知监听
    [[NSNotificationCenter defaultCenter]removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    _isPlaying  = NO;
    //要在清理数据完后，再回调
    if (self.completeHandler) {
        self.completeHandler(YES, nil);
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
