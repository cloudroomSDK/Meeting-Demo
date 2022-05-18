//
//  MessageViewController.h
//  Meeting
//
//  Created by YunWu01 on 2021/11/9.
//

#import <Cocoa/Cocoa.h>
#import "MChatModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MessageViewControllerSendMessageBlock) (NSString *text);

@interface MessageViewController : NSViewController
@property (nonatomic, strong) NSMutableArray<MChatModel *> *messages;
@property (nonatomic, copy) MessageViewControllerSendMessageBlock textFieldShouldReturn; /**< "发送"按钮响应 */

- (void)reloadTableView;
- (void)clearTextField;

@end

NS_ASSUME_NONNULL_END
