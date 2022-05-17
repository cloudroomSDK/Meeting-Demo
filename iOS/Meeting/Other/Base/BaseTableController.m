//
//  BaseTableController.m
//  VideoCall
//
//  Created by king on 2016/11/22.
//  Copyright © 2016年 CloudRoom. All rights reserved.
//

#import "BaseTableController.h"

@interface BaseTableController ()

@end

@implementation BaseTableController
#pragma mark - life cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _setupForbaseTable];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 显示导航栏
    if ([self.navigationController isNavigationBarHidden]) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

#pragma mark - private method
- (void)_setupForbaseTable
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    if (self.tableView) {
        [self.tableView setTableFooterView:[UIView new]];
    }
}
@end
