//
//  PSBottomView.h
//  Meeting
//
//  Created by king on 2018/6/27.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PSBottomView, PMRoundTextField, PMRoundBtn;

typedef void (^PSBottomViewResponse)(PSBottomView *view, UIButton *sender);

@interface PSBottomView : UIView

@property (nonatomic, weak) IBOutlet PMRoundTextField *serverTextField; /**< 服务器地址 */
@property (nonatomic, weak) IBOutlet PMRoundTextField *userTextField; /**< 用户名 */
@property (nonatomic, weak) IBOutlet PMRoundTextField *paswdTextField; /**< 密码 */
@property (nonatomic, weak) IBOutlet PMRoundTextField *rsaTextField; /**< 密码 */

@property (nonatomic, weak) IBOutlet PMRoundBtn *reset;
@property (nonatomic, weak) IBOutlet PMRoundBtn *datEncTypeBtn;

@property (nonatomic, copy) PSBottomViewResponse response; /**< 按钮响应 */

@end
