//
//  QMAnimationUserInfoView.m
//  StarMaker
//
//  Created by yuanpinghua on 2019/7/29.
//  Copyright © 2019 uShow. All rights reserved.
//
#import "QMAnimationUserInfoView.h"
#import <SDAnimatedImageView.h>
#import "CommonMacro.h"
@interface QMAnimationUserInfoView ()
@property (nonatomic,strong) UIImageView * userHeaderView;///<用户头像 有挂件时52*52,没有时70*70
@property (nonatomic,strong) SDAnimatedImageView *userHeadPendant;///<用户头像挂件 大小110*110
@property (nonatomic,strong) UIImageView *userInfoBgView;///<用户信息背景 距两边宽度30
@property (nonatomic,strong) UILabel *userInfoLabel;///<用户信息
@end

@implementation QMAnimationUserInfoView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubViews];
        [self addConstraintForSubViews];
    }
    return self;
}
- (void)createSubViews
{
    self.userInfoBgView = [UIImageView new];
    self.userInfoBgView.image = [UIImage imageNamed:@"icon_userinfo_bg"];
    [self addSubview:self.userInfoBgView];
    self.userInfoLabel = [UILabel new];
    self.userInfoLabel.textColor = mRGBToAlpColor(0xffffff,1);
    self.userInfoLabel.font = [UIFont boldSystemFontOfSize:14];
    self.userInfoLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.userInfoLabel];
    self.userHeaderView = [UIImageView new];
    [self addSubview:self.userHeaderView];
    self.userHeadPendant = [SDAnimatedImageView new];
    [self addSubview:self.userHeadPendant];
}

-(void)addConstraintForSubViews
{
    [self.userInfoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(30);
        make.right.equalTo(self).offset(-30);
        make.height.mas_equalTo(50);
        make.bottom.equalTo(self);
    }];
    
    [self.userInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.userInfoBgView);
        make.left.equalTo(self.userInfoBgView).offset(20);
    }];
    
    [self.userHeadPendant mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.userInfoBgView);
        make.bottom.equalTo(self.userInfoBgView.mas_top).offset(19);
        make.size.mas_equalTo(CGSizeMake(110,110));
    }];
    
    [self.userHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.userHeadPendant);
         make.size.mas_equalTo(CGSizeMake(52,52));
    }];
}
-(void)updateWithUserInfo:(NSString*)userName
          userHeaderImage:(NSString*)headerImage
          userHeadPendant:(NSString*)headPendant
{
    if (!NULLString(headPendant)) {
        [self.userHeaderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.userHeadPendant);
            make.size.mas_equalTo(CGSizeMake(52,52));
        }];
        self.userHeaderView.layer.cornerRadius = 26;
    } else {
        [self.userHeaderView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.userHeadPendant);
            make.size.mas_equalTo(CGSizeMake(72,72));
            make.bottom.equalTo(self.userInfoBgView.mas_top);
        }];
        self.userHeaderView.layer.cornerRadius = 36;

        
    }
    self.userHeaderView.layer.masksToBounds = YES;
    self.userHeaderView.layer.borderColor = UIColor.whiteColor.CGColor;
    self.userHeaderView.layer.borderWidth = 1;
    [self.userHeaderView sd_setImageWithURL:[NSURL URLWithString:headerImage]];
    if (!NULLString(headPendant)) {
        if ([headPendant hasPrefix:@"http://"]||[headPendant hasPrefix:@"https://"]) {
            [self.userHeadPendant sd_setImageWithURL:[NSURL URLWithString:headPendant]];
        }else{
            self.userHeadPendant.image = [UIImage imageNamed:headPendant];
        }
    }
    self.userInfoLabel.text = userName;
}
@end
