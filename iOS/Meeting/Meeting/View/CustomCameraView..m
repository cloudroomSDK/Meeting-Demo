//
//  MTwoTwoView.m
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "CustomCameraView.h"
#import "Masonry.h"

@interface CustomCameraView()

@end

@implementation CustomCameraView
#pragma mark - lazying
-(UIImageView *)placeImage
{
    if(_placeImage == nil)
    {
        _placeImage = [[UIImageView alloc]init];
        _placeImage.image = [UIImage imageNamed:@"meeting_place_holder"];
    }
    return _placeImage;
}

-(UILabel *)titleLabel
{
    if(_titleLabel == nil)
    {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.layer.cornerRadius = 6;
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.backgroundColor = UIColorFromRGBA(0, 0, 0, 0.3);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        
    }
    return _titleLabel;
}
#pragma mark - init
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI
{
    [self setBackgroundColor:UIColorFromRGBA(31, 47, 65, 1.0)];
    [self addSubview: self.placeImage];
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self).offset(4);
        make.top.equalTo(self).offset(2);
    }];
    
    [self.placeImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self);
        make.width.mas_equalTo(65);
        make.height.mas_equalTo(65);
    }];
}

//#pragma mark - override
- (void)setUsrVideoId:(UsrVideoId *)usrVideoId {
    [super setUsrVideoId:usrVideoId];

    BOOL value = usrVideoId ? YES : NO;
    _placeImage.hidden = value;
    _titleLabel.text = [[CloudroomVideoMeeting shareInstance] getNickName:usrVideoId.userId];
    
    if (!value) {
        [self clearFrame];
        [self setBackgroundColor:UIColorFromRGBA(31, 47, 65, 1.0)];
    }
}
@end
