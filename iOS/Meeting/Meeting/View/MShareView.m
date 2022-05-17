//
//  MShareView.m
//  Meeting
//
//  Created by king on 2018/7/2.
//  Copyright © 2018年 BossKing10086. All rights reserved.
//

#import "MShareView.h"

@interface MShareView ()

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *shareW;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *shareH;

@end

@implementation MShareView
#pragma mark - life cycle
- (void)awakeFromNib {
    [super awakeFromNib];
    [self _commonSetup];
}

#pragma mark - private method
- (void)_commonSetup {
    _shareSrcSize = CGSizeZero;
    
    self.alpha = 0;
}

- (void)_updateUIScreen {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat shareW = 0;
    CGFloat shareH = 0;
    
    if (_shareSrcSize.width == 0 || _shareSrcSize.height == 0) {
        shareW = 0;
        shareH = 0;
    }
    else {
        shareW = width;
        shareH = width * _shareSrcSize.height / _shareSrcSize.width;
        
        if (shareH > height) {
            shareH = height;
            shareW = height * _shareSrcSize.width / _shareSrcSize.height;
        }
    }
    
    MLog(@"_updateUIScreen w:%f h:%f itemW:%f itemH:%f", width, height, shareW, shareH);
    _shareW.constant = shareW;
    _shareH.constant = shareH;
}

#pragma mark - getter & setter
- (void)setShareSrcSize:(CGSize)shareSrcSize {
    _shareSrcSize = shareSrcSize;
    
    [self _updateUIScreen];
}
@end
