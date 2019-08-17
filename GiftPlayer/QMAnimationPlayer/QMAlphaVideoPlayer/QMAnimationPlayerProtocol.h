//
//  QMAnimationPlayerProtocol.h
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/16.
//  Copyright © 2019 uShow. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QMAnimationPlayerProtocol <NSObject>
-(void)pause;///<暂停
-(void)resume;///<继续播放
-(void)stop;///<停止播放
@end

NS_ASSUME_NONNULL_END
