//
//  MChatCell.h
//  Meeting
//
//  Created by king on 2018/7/9.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MChatModel;

@interface MChatCell : UITableViewCell

@property (nonatomic, strong) MChatModel *model; /**< 消息 */

- (CGFloat)heightForModel:(MChatModel *)model;

@end
