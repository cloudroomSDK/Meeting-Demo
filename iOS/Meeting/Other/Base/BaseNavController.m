//
//  BaseNavController.m
//  VideoCall
//
//  Created by king on 2016/11/22.
//  Copyright © 2016年 CloudRoom. All rights reserved.
//

#import "BaseNavController.h"

@interface BaseNavController ()

@end

@implementation BaseNavController
#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupUIForBaseNav];
}

#pragma mark - private method
- (void)_setupUIForBaseNav
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    [navBar setTintColor:UIColorFromRGBA(48, 153, 251, 1.0)];
}
@end
