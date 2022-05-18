//
//  EditNicknameWindowController.m
//  Meeting
//
//  Created by YunWu01 on 2021/12/17.
//

#import "EditNicknameWindowController.h"

@interface EditNicknameWindowController ()
@property (weak) IBOutlet NSTextField *nicknameTF;
@end

@implementation EditNicknameWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)saveNicknameAction:(id)sender {
    NSString *nickname = _nicknameTF.stringValue;
    if (nickname.length > 0 && _EditNicknameBlock) {
        _EditNicknameBlock(nickname);
        _nicknameTF.stringValue = @"";
        [self close];
    }
}

@end
