//
//  QMAnimatedImageView.h
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/16.
//  Copyright © 2019 uShow. All rights reserved.
//

#import "SDAnimatedImageView.h"
#import "QMAnimationPlayerProtocol.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^AnimationDidFinish)(BOOL finish);
@interface QMAnimatedImageView: SDAnimatedImageView<QMAnimationPlayerProtocol>
@property (nonatomic, copy) AnimationDidFinish animationDidFinishHandler;
-(void)pause;
-(void)stop;
-(void)resume;

/**
 开始动画状态检测
 */
-(void)startAnimatingStatusCheck;
@end

NS_ASSUME_NONNULL_END
