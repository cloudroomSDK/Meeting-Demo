//
//  MChatModel.h
//  Meeting
//
//  Created by king on 2018/7/9.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MChatModel : NSObject

@property (nonatomic, copy) NSString *name; /**< 昵称 */
@property (nonatomic, copy) NSString *content; /**< 内容 */
@property (nonatomic, assign) CGFloat cacheH; /**< 缓存高度 */

- (instancetype)initWithName:(NSString *)name content:(NSString *)content;

@end
