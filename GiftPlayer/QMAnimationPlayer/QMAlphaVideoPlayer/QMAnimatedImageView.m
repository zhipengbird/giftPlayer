//
//  QMAnimatedImageView.m
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/16.
//  Copyright © 2019 uShow. All rights reserved.
//

#import "QMAnimatedImageView.h"
@interface QMAnimatedImageView()
@property (nonatomic, strong) CADisplayLink *displayAnimationLink;///<用于轮循SDAnimatedImageView播放状态
@property (nonatomic, assign) BOOL isPause;///<是否暂停
@end

@implementation QMAnimatedImageView
- (void)pause {
    self.isPause = YES;
    self.displayAnimationLink.paused = YES;
    [self stopAnimating];
}

- (void)resume {
    self.isPause = NO;
    self.displayAnimationLink.paused = NO;
    [self startAnimating];
}

- (void)stop {
    [self.displayAnimationLink invalidate];
    [self stopAnimating];
    if (self.animationDidFinishHandler) {
        self.animationDidFinishHandler(YES);
    }
}

-(void)startAnimatingStatusCheck{
    self.displayAnimationLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkAnimating)];
    self.displayAnimationLink.paused = NO;
    [self.displayAnimationLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

-(void)checkAnimating{
    if (self.isAnimating || self.isPause) {
        
    }else{
        [self.displayAnimationLink invalidate];
        self.displayAnimationLink = nil;
        if (self.animationDidFinishHandler) {
            self.animationDidFinishHandler(YES);
        }
    }
}

@end
