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
    [navBar setTintColor:[UIColor whiteColor]]; // 文字标题颜色
    [navBar setBarTintColor:UIColorFromRGBA(48, 153, 251, 1.0)];
    
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    textAttrs[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18.0f];
    textAttrs[NSKernAttributeName] = @(1.0);
    if (@available(iOS 15.0, *)) {
        
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        
        appearance.titleTextAttributes = textAttrs;
        appearance.backgroundColor = UIColorFromRGBA(48, 153, 251, 1.0); // 背景颜色
        appearance.shadowImage = [UIImage new];
        
        navBar.scrollEdgeAppearance = appearance;
        navBar.standardAppearance = appearance;
    }
}
@end
