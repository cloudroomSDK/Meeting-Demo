//
//  MShareView.h
//  Meeting
//
//  Created by king on 2018/7/2.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

@interface MShareView : UIView

@property (nonatomic, weak) IBOutlet CLShareView *shareImageView;
@property (nonatomic, weak) IBOutlet CLBrushView *brushView;
@property (nonatomic, assign) CGSize shareSrcSize;

@end
