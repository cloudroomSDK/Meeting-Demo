//
//  MChatModel.m
//  Meeting
//
//  Created by king on 2018/7/9.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MChatModel.h"

@implementation MChatModel
#pragma mark - life cycle
- (instancetype)initWithName:(NSString *)name content:(NSString *)content {
    self = [super init];
    
    if (!self) {
        return nil;
    }
    
    _name = name;
    _content = content;
    
    return self;
}
@end
