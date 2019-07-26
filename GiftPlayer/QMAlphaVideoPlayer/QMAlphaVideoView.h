//
//  QMVideoView.h
//  QMAnimationPlayerTest
//
//  Created by yuanpinghua on 2019/7/18.
//  Copyright © 2019 yuanpinghua. All rights reserved.
//

#import "GPUImageView.h"
#import "QMAnimationPlayerProtocol.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^QMAlphaVideoPlayerDidFinish)(BOOL finish,NSError * _Nullable error);
@interface QMAlphaVideoView : UIView<QMAnimationPlayerProtocol>
-(void)playVideoWithSource:(NSURL*)source completeHandler:(QMAlphaVideoPlayerDidFinish)completeHandler;
-(void)pause;
-(void)resume;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
