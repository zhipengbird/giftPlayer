//
//  QMSVGAPlayerView.h
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/16.
//  Copyright © 2019 uShow. All rights reserved.
//

#import "SVGAPlayer.h"
#import "QMAnimationPlayerProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface QMSVGAPlayerView : SVGAPlayer<QMAnimationPlayerProtocol>
-(void)pause;
-(void)resume;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
