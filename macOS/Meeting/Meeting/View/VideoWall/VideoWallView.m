//
//  VideoWallView.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/6.
//

#import "VideoWallView.h"

@implementation VideoWallView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}


-(void)updateVideo:(NSView*)view data:(NSArray<UsrVideoId *> *)dataSource
{
    NSArray<NSView *>* subViews = [view subviews];
    
    for (int i = 0; i< [subViews count]; i++)
    {
        CLCameraView* desView = (CLCameraView*)subViews[i];
        UsrVideoId *videoID = i<[dataSource count]? dataSource[i]:nil;
        if (![desView.usrVideoId.userId isEqualToString:videoID.userId] || desView.usrVideoId.videoID != videoID.videoID) {
            [desView setUsrVideoId:videoID];
        }
    }
    
    for (CLCameraView* desView in subViews) {
        if (desView.usrVideoId == nil) {
            [desView clearFrame];
        }
    }
    
}

-(void)clearVideo:(NSView*)view
{
    NSArray<NSView *>* subViews = [view subviews];
    
    for (NSView* obj in subViews)
    {
        CLCameraView* desView = (CLCameraView*)obj;
        [desView setUsrVideoId:nil];
        [desView clearFrame];
        
    }
}

#pragma mark - public method
- (void)updateUIViews:(NSArray<UsrVideoId *> *)dataSource localer:(NSString *)localer {
    NSUInteger count = [dataSource count];
  
#if 0
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
    } else if (count == 6) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
    } else if (count == 7) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
    } else if (count == 8) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
    } else if (count >=9) {
        self.type = MContentViewTypeNine;
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
    } else {
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
        [self clearVideo:_nineView];
    }
#else
    if (_type == MContentViewType_2) {
        [self updateVideo:_twoView data:dataSource];
        [self clearVideo:_fourView];
        [self clearVideo:_nineView];
    } else if (_type == MContentViewType_4) {
        [self updateVideo:_fourView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_nineView];
    } else if (_type == MContentViewType_6) {
        [self updateVideo:_nineView data:dataSource];
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
    } else {
        [self clearVideo:_twoView];
        [self clearVideo:_fourView];
        [self clearVideo:_nineView];
    }
#endif
}


#pragma mark - private method
- (void)_commonSetup {
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor blackColor].CGColor;
}

#pragma mark - getter & setter
- (void)setType:(MContentViewType)type {
    _type = type;
    
    switch (type) {
        case MContentViewType_2: {
            [_twoView setHidden:NO];
            [_fourView setHidden:YES];
            [_nineView setHidden:YES];
            
            break;
        }
        case MContentViewType_4: {
            [_twoView setHidden:YES];
            [_fourView setHidden:NO];
            [_nineView setHidden:YES];
            
            break;
        }
        case MContentViewType_6: {
            [_twoView setHidden:YES];
            [_fourView setHidden:YES];
            [_nineView setHidden:NO];
            
            break;
        }
            
        default:
            break;
    }
}

@end
