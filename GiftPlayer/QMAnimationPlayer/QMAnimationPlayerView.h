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
    QMGiftAnimationTypeSVGA,///SVGA
    QMGiftAnimationTypeWebp,///Webp
    QMGiftAnimationTypeMp4,///mp4
};

typedef NSString * QMAnimationContextOption NS_EXTENSIBLE_STRING_ENUM;
extern QMAnimationContextOption _Nonnull const QMAnimationContextSVGAImageSource;///<SVGA动画中需要替换的资源
extern QMAnimationContextOption _Nonnull const QMAnimationContextSVGAImageSourceKey;///<SVGA动画中需要替换对应资源的Key
extern QMAnimationContextOption _Nonnull const QMAnimationContextSVGADescription;///<在SVGA中需要替换的文本信息
extern QMAnimationContextOption _Nonnull const QMAnimationContextSVGADescriptionKey;///<在SVGA中需要替换的文本信息对应的Key

extern QMAnimationContextOption _Nonnull const QMAnimationContextImageSource;///<要额外加载图片资源。在非SVGA动画中表示底部要展示的图片
extern QMAnimationContextOption _Nonnull const QMAnimationContextDescription;///<要处理的额外信息,在非SVGA动画中表示底部要展示的文本信息

extern QMAnimationContextOption _Nonnull const QMAnimationContextShouldShowSender;///<是否需要对图片做圆角处理
extern QMAnimationContextOption _Nonnull const QMAnimationContextHeadPendant;///<用户头像挂件
extern QMAnimationContextOption _Nonnull const QMAnimationContextContentMode;///<内容显示模式，UIViewContentMode

typedef void(^QMAnimationFinishBlock)(BOOL complete, NSError  * _Nullable error);

/**
 QMAnimationPalyer支持SVGA、Webp、mp4三种类型的礼物动画。
 */
@interface QMAnimationPlayerView : UIView


/**
 礼物播放入口API
 示例：
 播入一个SVGA动画，播放时需要替换对应key图片，和文本描述
 [QMAnimationPlayer playWithSource:@"" animationType:QMSVGAGiftAnimationType extralParam:@{QMAnimationContextImageSource:@"http://XXXX.png",
 QMAnimationContextImageSourceKey:@"img_193",
 QMAnimationContextDescription:@"XXXX",
 QMAnimationContextDescriptionKey:@"img_350"}
 finishBlock:^(BOOL complete, NSError *error){
 
 }]
 @param source 资源路径
 @param type 动画类型
 @param params  附加参数 参阅 QMAnimationContextOption 的定义
 @param finishBlock 完成回调
 */
-(void)playWithSource:(NSString*)source
        animationType:(QMGiftAnimationType)type
          extraParams:(NSDictionary*)params
          finishBlock:(QMAnimationFinishBlock)finishBlock;

/**
 礼物播放入口API 传入一个本地视频资源时，可以使用这个接品，不需要指定动画类型，内部根据文件后缀来判断动画类型

 @param source 本地资源地址
 @param params 附加参数 参阅 QMAnimationContextOption 的定义
 @param finishBlock 完成回调
 */
-(void)playWithSource:(NSString*)source
          extraParams:(NSDictionary*)params
          finishBlock:(QMAnimationFinishBlock)finishBlock;
/**
 暂停动画
 */
-(void)pause;

/**
 继续动画
 */
-(void)resume;

/**
 停止动画
 */
-(void)stop;
@end

NS_ASSUME_NONNULL_END
