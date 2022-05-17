//
//  MNineOneView.m
//  Meeting
//
//  Created by king on 2018/6/28.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MNineOneView.h"

@implementation MNineOneView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - private method
- (void)_commonSetup {
    [self setBackgroundColor:UIColorFromRGBA(31, 47, 65, 1.0)];
    
    _placeImage.image = [UIImage imageNamed:@"meeting_place_holder"];
    
    _titleLabel.layer.cornerRadius = 6;
    _titleLabel.layer.masksToBounds = YES;
    _titleLabel.backgroundColor = UIColorFromRGBA(0, 0, 0, 0.3);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
}

#pragma mark - override
- (void)setUsrVideoId:(UsrVideoId *)usrVideoId {
    [super setUsrVideoId:usrVideoId];
    BOOL value = usrVideoId ? YES : NO;
    _placeImage.hidden = value;
    _titleLabel.text = usrVideoId.userId;

    if (!value) {
        [self clearFrame];
        [self setBackgroundColor:UIColorFromRGBA(31, 47, 65, 1.0)];
    }
}
@end
