//
//  QMAnimationPlayer.m
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/15.
//  Copyright © 2019 uShow. All rights reserved.
//

#import "QMAnimationPlayerView.h"

#import <SDWebImage.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>

#import "SVGA.h"
#import "QMSVGAPlayerView.h"
#import "QMAlphaVideoView.h"
#import "QMAnimatedImageView.h"
#import "QMAnimationUserInfoView.h"
#import "CommonMacro.h"

QMAnimationContextOption const QMAnimationContextSVGAImageSource = @"SVGAImageSource";///<SVGA动画中需要替换的资源
QMAnimationContextOption const QMAnimationContextSVGADescription = @"SVGADescription";///<在SVGA中需要替换的文本信息
QMAnimationContextOption const QMAnimationContextSVGAImageSourceKey = @"SVGAImageSourceKey";
QMAnimationContextOption const QMAnimationContextSVGADescriptionKey = @"SVGADescriptionKey";

QMAnimationContextOption const QMAnimationContextImageSource = @"imageSource";
QMAnimationContextOption const QMAnimationContextDescription = @"description";
QMAnimationContextOption const QMAnimationContextShouldShowSender = @"showSender";
QMAnimationContextOption const QMAnimationContextHeadPendant = @"headPendant";

QMAnimationContextOption const QMAnimationContextContentMode = @"contentMode";

@interface QMAnimationPlayerView ()<SVGAPlayerDelegate>
@property (nonatomic, strong) QMSVGAPlayerView *svgaPlayer;///<SVGA播放视图
@property (nonatomic, strong) SVGAParser *svgaParser;///SVGA解析器
@property (nonatomic, strong) QMAlphaVideoView *videoPlayerView;///<alpha视频播放

@property (nonatomic, strong) QMAnimatedImageView *animatedImageView;///<webp播放视图

@property (nonatomic, assign) QMGiftAnimationType animationType;///<当前动画类型
@property (nonatomic, copy) QMAnimationFinishBlock finishBlock;///<动画完成的回调
@property (nonatomic, strong) NSDictionary *extraParams;///<附加参数
@property (nonatomic, strong) QMAnimationUserInfoView * userInfoView;///<底部用户信息

@property (nonatomic, weak) UIView<QMAnimationPlayerProtocol> * currentPlayView;

@property (nonatomic, assign) BOOL isAnimating;///<是否正在动画中
@end

@implementation QMAnimationPlayerView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createUserinfoView];
    }
    return self;
}
-(void)createUserinfoView{
    self.userInfoView = [QMAnimationUserInfoView new];
    self.userInfoView.alpha = 0;

    [self addSubview:self.userInfoView];
    [self.userInfoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(150);
        make.bottom.equalTo(self).offset(-SCREEN_HEIGH * 50/375.0);
    }];
}
-(void)playWithSource:(NSString *)source extraParams:(NSDictionary *)params finishBlock:(QMAnimationFinishBlock)finishBlock{

    if (NULLString(source)) {
        if (finishBlock) {
            finishBlock(NO,nil);
        }
        return;
    }
    //    检测后缀名检测文件类型
    NSString * fileExtension = source.pathExtension.lowercaseString;
    QMGiftAnimationType animationType ;
    if ([fileExtension isEqualToString:@"mp4"]) {
        animationType = QMGiftAnimationTypeMp4;
    }else if ([fileExtension isEqualToString:@"svga"]){
        animationType = QMGiftAnimationTypeSVGA;
    }else if ([fileExtension isEqualToString:@"webp"]){
        animationType = QMGiftAnimationTypeWebp;
    }else {
        NSLog(@"未知动画类型，该控件不支持");
        if (finishBlock) {
            finishBlock(NO,nil);
        }
        return;
    }
    
    [self playWithSource:source animationType:animationType extraParams:params finishBlock:finishBlock];
}

-(void)playWithSource:(NSString *)source
        animationType:(QMGiftAnimationType)type
          extraParams:(NSDictionary *)params
          finishBlock:(nonnull QMAnimationFinishBlock)finishBlock{
    ///检测礼物类型
    NSURL * url = [self urlWithSource:source];
    
    if (!url ) {
        if (finishBlock) {
            finishBlock(NO,nil);
        }
        return;
    }
    ///<如果当前已有动画在播放，则直接停止，播入新动画
    if (self.isAnimating) {
        [self stop];
    }
    self.animationType = type;
    @weakify(self)
    self.finishBlock = ^(BOOL complete, NSError * _Nullable error) {
        @strongify(self)
        self.isAnimating = NO;///<回调前，将播放状态置为NO
        [self hiddenUserInfoViewAnimation];
        if(finishBlock){
            finishBlock(complete,error);
        }
    };
    self.extraParams = params;
    self.isAnimating = YES;
    NSLog(@"开始播放动画:%@",source);
    ///根据不同的礼物类型创建不同的礼物播放对象
    switch (type) {
        case QMGiftAnimationTypeSVGA:
            self.currentPlayView = [self playSVGAAnimationWithSource:url];
            break;
        case QMGiftAnimationTypeWebp:
            self.currentPlayView = [self playWebpAnimationWithSource:url];
            break;
        case QMGiftAnimationTypeMp4:
            self.currentPlayView = [self playAlphaVideoAnimationWithSource:url];
            break;
    }
    if (self.currentPlayView) {
        ///如果当前放视频不为空，则将其提到视图前面
        [self bringSubviewToFront:self.currentPlayView];
        [self checkAndShowUserInfoView];
    }else{
        if (self.finishBlock) {
            self.finishBlock(NO, nil);
        }
    }
}

- (void)checkAndShowUserInfoView{
    //检测是否需要展示发送者用户信息
    if (![self.extraParams[QMAnimationContextShouldShowSender] boolValue]) {
        return;
    }
    NSString * headImage = self.extraParams[QMAnimationContextImageSource];
    NSString * descInfo =  self.extraParams[QMAnimationContextDescription];
    NSString * headPendant = self.extraParams[QMAnimationContextHeadPendant];
    if (!NULLString(headImage) && !NULLString(descInfo)) {
        [self.userInfoView updateWithUserInfo:descInfo userHeaderImage:headImage userHeadPendant:headPendant];
        [self bringSubviewToFront:self.userInfoView];
        [UIView animateWithDuration:0.3 animations:^{
            self.userInfoView.alpha = 1;
        }];
    }
}
-(void)hiddenUserInfoViewAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        self.userInfoView.alpha = 0;
    }];
}

-(UIView<QMAnimationPlayerProtocol>*)playSVGAAnimationWithSource:(NSURL *)sourceUrl {
    if (!sourceUrl) {
        if (self.finishBlock) {
            self.finishBlock(NO, nil);
        }
        return nil;
    }
    if (!self.svgaPlayer) {
        _svgaPlayer = [[QMSVGAPlayerView alloc] initWithFrame:self.bounds];
        _svgaPlayer.delegate = self;
        _svgaPlayer.loops = 1;
        _svgaPlayer.clearsAfterStop = YES;
        [self addSubview:_svgaPlayer];
    }
    [self bringSubviewToFront:_svgaPlayer];
    if (self.extraParams && [self.extraParams.allKeys containsObject:QMAnimationContextContentMode]) {
        self.svgaPlayer.contentMode = [self.extraParams[QMAnimationContextContentMode] unsignedIntegerValue];
    }else{
        self.svgaPlayer.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    if (!self.svgaParser) {
        self.svgaParser = [[SVGAParser alloc] init];
    }
    
    NSString *replaceImageURL = self.extraParams[QMAnimationContextSVGAImageSource];
    NSString *replaceImageKey = self.extraParams[QMAnimationContextSVGAImageSourceKey];
    @weakify(self)
    if(!NULLString(replaceImageURL) && !NULLString(replaceImageKey)){
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:replaceImageURL]
                                                    options:SDWebImageHighPriority
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {}
                                                  completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                                      __block  UIImage *replaceImage = image?image:[UIImage imageNamed:@"placehold_icon"];
                                                      [self.svgaParser parseWithURL:sourceUrl
                                                                    completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
                                                                        @strongify(self)
                                                                        if (videoItem) {
                                                                                replaceImage = [self circleImage:replaceImage];
                                                                            
                                                                            NSString *replaceDescSource = self.extraParams[QMAnimationContextSVGADescription];
                                                                            NSString *replaceDescekey = self.extraParams[QMAnimationContextSVGADescriptionKey];
                                                                            if (!NULLString(replaceDescSource) && !NULLString(replaceDescekey)) {
                                                                                NSAttributedString *text = [[NSAttributedString alloc]
                                                                                                            initWithString:replaceDescSource
                                                                                                            attributes:@{
                                                                                                                         NSForegroundColorAttributeName:
                                                                                                                             mRGBToAlpColor(0xffe0a4, 1.0),
                                                                                                                         NSFontAttributeName:
                                                                                                                             [UIFont boldSystemFontOfSize:28.0]
                                                                                                                         
                                                                                                                         }];
                                                                                [self.svgaPlayer setAttributedText:text forKey:replaceDescekey];
                                                                            }
                                                                            [self.svgaPlayer setImage:replaceImage forKey:replaceImageKey];
                                                                            
                                                                            self.svgaPlayer.videoItem = videoItem;
                                                                            [self.svgaPlayer startAnimation];
                                                                        }else{
                                                                            //回调给外部
                                                                            
                                                                            if (self.finishBlock) {
                                                                                self.finishBlock(NO, nil);
                                                                            }
                                                                        }
                                                                    } failureBlock:^(NSError * _Nullable error) {
                                                                        @strongify(self)
                                                                        //回调给外部
                                                                        if (self.finishBlock) {
                                                                            self.finishBlock(NO, error);
                                                                        }
                                                                    }];
                                                  }];
    }else{
        [self.svgaParser parseWithURL:sourceUrl
                      completionBlock:^(SVGAVideoEntity * _Nullable videoItem) {
                          @strongify(self)
                          if (videoItem) {
                              self.svgaPlayer.videoItem = videoItem;
                              [self.svgaPlayer startAnimation];
                          }else{
                              //回调给外部
                              if (self.finishBlock) {
                                  self.finishBlock(NO, nil);
                              }
                          }
                      } failureBlock:^(NSError * _Nullable error) {
                          @strongify(self)
                          // 回调给外部
                          if (self.finishBlock) {
                              self.finishBlock(NO, error);
                          }
                      }];
    }
    return self.svgaPlayer;
    
}
-(UIView<QMAnimationPlayerProtocol>*)playWebpAnimationWithSource:(NSURL *)sourceURL{
    if(!sourceURL){
        if (self.finishBlock) {
            self.finishBlock(NO, nil);
        }
        return nil;
    }
    
    if (!self.animatedImageView) {
        _animatedImageView = [[QMAnimatedImageView alloc] initWithFrame:self.bounds];
        _animatedImageView.shouldCustomLoopCount = YES;///<用户自定义播放次数
        _animatedImageView.animationRepeatCount = 1;///<只播放一次
        _animatedImageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:_animatedImageView];
    }
    [self bringSubviewToFront:_animatedImageView];
    @weakify(self)
    self.animatedImageView.animationDidFinishHandler = ^(BOOL finish) {
        @strongify(self)
        if (self.finishBlock && self.animationType == QMGiftAnimationTypeWebp) {
            self.finishBlock(YES, nil);
        }
    };
    
    [ self.animatedImageView sd_setImageWithURL:sourceURL placeholderImage:nil
                                        options:SDWebImageProgressiveLoad context:@{SDWebImageContextStoreCacheType:@(SDImageCacheTypeDisk)}
                                       progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                                           
                                       }
                                      completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                          @strongify(self)
                                          if (!error) {
                                              [self.animatedImageView startAnimatingStatusCheck];
                                          }else{
                                              if (self.finishBlock) {
                                                  self.finishBlock(NO, error);
                                              }
                                              
                                          }
                                      }];
    return self.animatedImageView;
    
}

-(UIView<QMAnimationPlayerProtocol>*)playAlphaVideoAnimationWithSource:(NSURL *)source{
    if (!source) {
        if (self.finishBlock) {
            self.finishBlock(NO, nil);
        }
        return nil;
    }
    if (!_videoPlayerView) {
        _videoPlayerView = [[QMAlphaVideoView alloc] initWithFrame:self.bounds];
        [self addSubview:_videoPlayerView];
    }
    [self bringSubviewToFront:_videoPlayerView];
    @weakify(self)
    [self.videoPlayerView playVideoWithSource:source completeHandler:^(BOOL finish, NSError * _Nullable error) {
        @strongify(self)
        if (self.finishBlock) {
            self.finishBlock(finish, error);
        }
    }];
    return self.videoPlayerView;
}

-(void)pause{
    if (self.currentPlayView) {
        [self.currentPlayView pause];
    }
}
-(void)resume{
    if (self.currentPlayView) {
        [self.currentPlayView resume];
    }
}
- (void)stop{
    if (self.currentPlayView) {
        [self.currentPlayView stop];
    }
}

#pragma mark - clear

/**
 清理SVGA相关资源
 */
- (void)disposeSVGAPlayer {
    if (self.svgaPlayer) {
        [self.svgaPlayer removeFromSuperview];
        [self.svgaPlayer clear];
        [self.svgaPlayer clearDynamicObjects];
        self.svgaPlayer = nil;
        self.svgaParser = nil;
    }
}
-(void)disposeAnimatedImageView{
    if (self.animatedImageView) {
        [self.animatedImageView removeFromSuperview];
        self.animatedImageView = nil;
    }
}
-(void)disposeAlphaVideoView{
    if (self.videoPlayerView) {
        [self.videoPlayerView removeFromSuperview];
        self.videoPlayerView = nil;
    }
}
#pragma mark  - utils
-(NSURL*)urlWithSource:(NSString*)source{
    if (NULLString(source)) {
        return nil;
    }
    if ([source hasPrefix:@"http://"]||[source hasPrefix:@"https://"]) {
        return [NSURL URLWithString:source];
    }else{
        return [NSURL fileURLWithPath:source];
    }
}
-(UIImage*)circleImage:(UIImage*)image
{
    CGFloat inset = 0.1f;
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor clearColor].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}
#pragma mark - SVGAPlayerDelegate
-(void)svgaPlayerDidFinishedAnimation:(SVGAPlayer *)player{
    player.videoItem = nil;
    [player clear];
    [player clearDynamicObjects];
    if (self.finishBlock && self.animationType == QMGiftAnimationTypeSVGA) {
        self.finishBlock(YES,nil);
    }
}
#pragma mark - 事件透传
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    return nil;
}

-(void)dealloc{
    ///释放前先停止所有动画
    [self stop];
    ///释放相应的动画视图资源
    [self disposeAnimatedImageView];
    [self disposeSVGAPlayer];
    [self disposeAlphaVideoView];
}
@end
