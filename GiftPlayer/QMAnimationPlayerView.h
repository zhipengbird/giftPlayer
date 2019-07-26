//
//  QMAnimationPlayer.h
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/15.
//  Copyright © 2019 uShow. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, QMGiftAnimationType) {
    QMSVGAGiftAnimationType,///SVGA
    QMWebpGiftAnimationType,///Webp
    QMMp4GiftAnimationType,///mp4
};

extern   NSString * const QMReplaceImageSource;///<要额外加载图片资源。在非SVGA动画中表示底部要展示的图片
extern  NSString * const QMReplaceImageKey;///<对加载的资源需要在SVGA中替换相应的key

extern NSString * const QMReplaceDescInfo;///<要处理的额外信息,在非SVGA动画中表示底部要展示的文本信息
extern  NSString * const QMReplaceDescKey;///<在SVGA中需要替换的文本信息对应的Key

extern NSString * const QMShouldCicrleImage;///<是否需要对图片做圆角处理
extern NSString * const QMViewContentMode;///<内容显示模式，UIViewContentMode
typedef void(^AnimationCompleteHandler)(BOOL complete,NSError  * _Nullable error);

/**
 QMAnimationPalyer支持SVGA、Webp、mp4三种类型的礼物动画。
 */
@interface QMAnimationPlayerView : UIView


/**
 礼物播放入口API
 示例：
 播入一个SVGA动画，播放时需要替换对应key图片，和文本描述
 [QMAnimationPlayer playWithSource:@"" animationType:QMSVGAGiftAnimationType extralParam:@{replaceImageSource:@"http://XXXX.png",replaceImageKey:@"img_193",replaceDescInfo:@"XXXX",replaceDescKey:@"img_350"} completeHandler:^(BOOL complete, NSError *error){
 
 }]
 @param source 资源路径
 @param type 动画类型
 @param params 附加参数
 @param completeHandler 完成回调
 */
-(void)playWithSource:(NSString*)source animationType:(QMGiftAnimationType)type extralParam:(NSDictionary*)params completeHandler:(AnimationCompleteHandler)completeHandler;

-(void)pause;
-(void)resume;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
