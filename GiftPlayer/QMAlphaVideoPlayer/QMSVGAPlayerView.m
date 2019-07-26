//
//  QMSVGAPlayerView.m
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/16.
//  Copyright © 2019 uShow. All rights reserved.
//

#import "QMSVGAPlayerView.h"

@implementation QMSVGAPlayerView

- (void)pause {
    [self pauseAnimation];
}

- (void)resume {
    [self startAnimation];
}

- (void)stop {
    [self stopAnimation];
}

@end
