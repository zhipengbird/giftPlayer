//
//  QMAnimationPlayer.m
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/15.
//  Copyright © 2019 uShow. All rights reserved.
//

#import "QMAnimationPlayerView.h"
#import "QMAlphaVideoView.h"
#import <SDWebImage.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import "SVGA.h"
#import "QMAnimatedImageView.h"
#import "QMSVGAPlayerView.h"
#import "CommonMacro.h"

NSString * const QMReplaceImageSource = @"QMReplaceImageSource";
NSString * const QMReplaceImageKey = @"QMReplaceImageKey";

NSString * const QMReplaceDescInfo = @"QMReplaceDescInfo";
NSString * const QMReplaceDescKey = @"QMReplaceDescKey";
NSString * const QMShouldCicrleImage = @"QMShouldCicrleImage";
NSString * const QMViewContentMode = @"QMViewContentMode";

@interface QMAnimationPlayerView ()<SVGAPlayerDelegate>
@property (nonatomic, strong) QMSVGAPlayerView *svgaPlayer;///<SVGA播放视图
@property (nonatomic, strong) SVGAParser *svgaParser;///SVGA解析器
@property (nonatomic, strong) QMAlphaVideoView *videoPlayerView;///<alpha视频播放

@property (nonatomic, strong) QMAnimatedImageView *animatedImageView;///<webp播放视图

@property (nonatomic, assign) QMGiftAnimationType animationType;///<当前动画类型
@property (nonatomic, copy) AnimationCompleteHandler completeHandler;///<动画完成的回调
@property (nonatomic, strong) NSDictionary *extralParams;///<附加参数
@property (nonatomic, strong) UIImageView *bottomImageView;///<底部图片
@property (nonatomic, strong) UILabel *descInfo;///描述信息

@property (nonatomic, weak) UIView<QMAnimationPlayerProtocol> * currentPlayView;

@property (nonatomic, assign) BOOL isAnimating;///<是否正在动画中
@end

@implementation QMAnimationPlayerView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[SDImageCodersManager sharedManager] addCoder:[SDImageWebPCoder sharedCoder]];
        //TODO::这两视图的具体显示，待定
        self.bottomImageView = [UIImageView new];
        self.descInfo = [UILabel new];
        [self addSubview:self.bottomImageView];
        [self addSubview:self.descInfo];
    }
    return self;
}
-(void)playWithSource:(NSString *)source animationType:(QMGiftAnimationType)type extralParam:(NSDictionary *)params completeHandler:(nonnull AnimationCompleteHandler)completeHandler{
    ///检测礼物类型
    NSURL * url = [self urlWithSource:source];
    ///<如果当前已有动画在播放，则直接返回，防止一个画面中有多个动画同时播
    if (!url || self.isAnimating) {
        if (completeHandler) {
            completeHandler(NO,nil);
        }
        return;
    }
    self.animationType = type;
    @weakify(self)
    self.completeHandler = ^(BOOL complete, NSError * _Nullable error) {
        @strongify(self)
        self.isAnimating = NO;///<回调前，将播放状态置为NO
        if(completeHandler){
            completeHandler(complete,error);
        }
    };
    self.extralParams = params;
    self.isAnimating = YES;
    
    ///根据不同的礼物类型创建不同的礼物播放对象
    switch (type) {
        case QMSVGAGiftAnimationType:
            self.currentPlayView =  [self playSVGAAnimationWithSource:url];
            break;
        case QMWebpGiftAnimationType:
            self.currentPlayView=  [ self playWebpAnimationWithSource:url];
            break;
        case QMMp4GiftAnimationType:
            self.currentPlayView = [self playAlphaVideoAnimationWithSource:url];
            break;
    }
    if (self.currentPlayView) {
        ///如果当前放视频不为空，则将其提到视图前面
        [self bringSubviewToFront:self.currentPlayView];
    }
}

-(UIView<QMAnimationPlayerProtocol>*)playSVGAAnimationWithSource:(NSURL *)sourceUrl {
    if (!sourceUrl) {
        if (self.completeHandler) {
            self.completeHandler(NO, nil);
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
    if (self.extralParams && [self.extralParams.allKeys containsObject:QMViewContentMode]) {
        self.svgaPlayer.contentMode = [self.extralParams[QMViewContentMode] unsignedIntegerValue];
    }else{
        self.svgaPlayer.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    if (!self.svgaParser) {
        self.svgaParser = [[SVGAParser alloc] init];
    }
    
    NSString *replaceImageURL = self.extralParams[QMReplaceImageSource];
    NSString *replaceImageKey = self.extralParams[QMReplaceImageKey];
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
                                                                            BOOL shouldCircle = [self.extralParams[QMShouldCicrleImage] boolValue];
                                                                            if (shouldCircle) {
                                                                                replaceImage = [self circleImage:replaceImage];
                                                                            }
                                                                            
                                                                            NSString *replaceDescSource = self.extralParams[QMReplaceDescInfo];
                                                                            NSString *replaceDescekey = self.extralParams[QMReplaceDescKey];
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
                                                                            
                                                                            if (self.completeHandler) {
                                                                                self.completeHandler(NO, nil);
                                                                            }
                                                                        }
                                                                    } failureBlock:^(NSError * _Nullable error) {
                                                                        @strongify(self)
                                                                        //并回调给外部
                                                                        if (self.completeHandler) {
                                                                            self.completeHandler(NO, nil);
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
                              //清理SVGA相关信息，并回调给外部
                              if (self.completeHandler) {
                                  self.completeHandler(NO, nil);
                              }
                          }
                      } failureBlock:^(NSError * _Nullable error) {
                          @strongify(self)
                          // 清理SVGA相关信息，并回调给外部
                          if (self.completeHandler) {
                              self.completeHandler(NO, nil);
                          }
                      }];
    }
    return self.svgaPlayer;
    
}
-(UIView<QMAnimationPlayerProtocol>*)playWebpAnimationWithSource:(NSURL *)sourceURL{
    if(!sourceURL){
        if (self.completeHandler) {
            self.completeHandler(NO, nil);
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
        [self disposeAnimatedImageView];
        if (self.completeHandler && self.animationType == QMWebpGiftAnimationType) {
            self.completeHandler(YES, nil);
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
                                              if (self.completeHandler) {
                                                  self.completeHandler(NO, nil);
                                              }
                                              
                                          }
                                      }];
    return self.animatedImageView;
    
}

-(UIView<QMAnimationPlayerProtocol>*)playAlphaVideoAnimationWithSource:(NSURL *)source{
    if (!source) {
        if (self.completeHandler) {
            self.completeHandler(NO, nil);
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
        if (self.completeHandler) {
            self.completeHandler(finish, error);
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
    [self disposeSVGAPlayer];
    if (self.completeHandler && self.animationType == QMSVGAGiftAnimationType) {
        self.completeHandler(YES,nil);
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
