//
//  MContentView.m
//  Meeting
//
//  Created by king on 2018/7/2.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MContentView.h"
#import "CustomCameraView.h"

#import "CRSDKHelper.h"

@implementation MContentView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}


-(void)updateVideo:(UIView*)view data:(NSArray<UsrVideoId *> *)dataSource
{
    NSArray<UIView *>* subViews = [view subviews];
    
    for (int i = 0; i< [subViews count]; i++)
    {
        CustomCameraView* desView = (CustomCameraView*)subViews[i];
        UsrVideoId *videoID = i<[dataSource count]? dataSource[i]:nil;
        [desView setUsrVideoId:videoID];
    }
    
}

-(void)clearVideo:(UIView*)view
{
    NSArray<UIView *>* subViews = [view subviews];
    
    for (UIView* obj in subViews)
    {
        CustomCameraView* desView = (CustomCameraView*)obj;
        [desView setUsrVideoId:nil];
        
    }
}

- (void)clearAllVideos {
    [self clearVideo:_twoView];
    [self clearVideo:_fourView];
    [self clearVideo:_nineView];
}

#pragma mark - public method
- (void)updateUIViews:(NSArray<UsrVideoId *> *)dataSource localer:(NSString *)localer {
    if (_shareStyle == YES) {
        return;
    }
    
    NSUInteger count = [dataSource count];
    
    if (count == 1) {
        self.type = MContentViewTypeTwo;
        [self updateVideo:_twoView data:dataSource];
        [self clearVideo:_fourView];
        [self clearVideo:_nineView];

    }else if (count == 2) {
        self.type = MContentViewTypeTwo;
        [self updateVideo:_twoView data:dataSource];
        [self clearVideo:_fourView];
        [self clearVideo:_nineView];

    } else if (count == 3) {
        self.type = MContentViewTypeFour;
        [self updateVideo:_fourView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_nineView];
        
    } else if (count == 4) {
        self.type = MContentViewTypeFour;
        [self updateVideo:_fourView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_nineView];
        
    }else if (count == 5) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
        
    } else if (count == 6) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
        
    } else if (count == 7) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
        
    } else if (count == 8) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
        
    } else if (count >=9) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
        
    } else {
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
        [self clearVideo:_nineView];
    }
}


#pragma mark - private method
- (void)_commonSetup {
    self.backgroundColor = UIColorFromRGBA(31, 47, 65, 1.0);
    _twoView.backgroundColor = [UIColor blackColor];
    _twoView.alpha = 0;
    _fourView.backgroundColor = [UIColor blackColor];
    _fourView.alpha = 0;
    _nineView.backgroundColor = [UIColor blackColor];
    _nineView.alpha = 0;
}

#pragma mark - getter & setter
- (void)setType:(MContentViewType)type {
    _type = type;
    
    switch (type) {
        case MContentViewTypeTwo: {
            [UIView animateWithDuration:0.25 animations:^{
                _twoView.alpha = 1.0;
                _fourView.alpha = 0;
                _nineView.alpha = 0;
            }];
            
            break;
        }
        case MContentViewTypeFour: {
            [UIView animateWithDuration:0.25 animations:^{
                _twoView.alpha = 0;
                _fourView.alpha = 1.0;
                _nineView.alpha = 0;
            }];
            
            break;
        }
        case MContentViewTypeNine: {
            [UIView animateWithDuration:0.25 animations:^{
                _twoView.alpha = 0;
                _fourView.alpha = 0;
                _nineView.alpha = 1.0;
            }];
            
            break;
        }
    }
}

- (void)setShareStyle:(BOOL)shareStyle {
    _shareStyle = shareStyle;
    // 如果不是视频墙状态，即开启了共享等要暂时清理视频渲染
    if (shareStyle == YES) {
        [self clearAllVideos];
    }
}

@end
