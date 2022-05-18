//
//  MemberViewController.h
//  Meeting
//
//  Created by YunWu01 on 2021/11/9.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MemberViewController : NSViewController
@property (nonatomic, strong) NSMutableArray<MemberInfo *> *members;

- (void)reloadTableView;

@end

NS_ASSUME_NONNULL_END
