//
//  QMAnimationUserInfoView.h
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/29.
//  Copyright © 2019 uShow. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QMAnimationUserInfoView : UIView

/**
 更新用户信息

 @param userName 用户名信息
 @param headerImage 用户头像
 @param headPendant 用户头像挂件
 */
-(void)updateWithUserInfo:(NSString *)userName
          userHeaderImage:(NSString *)headerImage
          userHeadPendant:(NSString * _Nullable)headPendant;
@end

NS_ASSUME_NONNULL_END
