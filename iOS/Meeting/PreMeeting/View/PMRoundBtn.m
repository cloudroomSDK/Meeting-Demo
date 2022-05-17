//
//  PMRoundBtn.m
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "PMRoundBtn.h"

@implementation PMRoundBtn
#pragma mark - getter & setter
- (void)setType:(PMRoundBtnType)type {
    _type = type;
    
    switch (type) {
        case PMRoundBtnTypeDark: {
            self.backgroundColor = UIColorFromRGBA(57, 171, 251, 1.0);
            self.titleLabel.font = [UIFont systemFontOfSize:16];
            self.layer.cornerRadius = 20;
            self.layer.masksToBounds = YES;
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
        case PMRoundBtnTypeLight: {
            self.backgroundColor = [UIColor whiteColor];
            self.titleLabel.font = [UIFont systemFontOfSize:16];
            self.layer.borderColor = UIColorFromRGBA(57, 171, 251, 1.0).CGColor;
            self.layer.borderWidth = 1;
            self.layer.cornerRadius = 20;
            self.layer.masksToBounds = YES;
            [self setTitleColor:UIColorFromRGBA(57, 171, 251, 1.0) forState:UIControlStateNormal];
            break;
        }
    }
}

- (void)setSelect:(BOOL)select {
    _select = select;
    
    self.backgroundColor = select ? UIColorFromRGBA(57, 171, 251, 1.0) : [UIColor lightGrayColor];
    self.enabled = _select;
}
@end
