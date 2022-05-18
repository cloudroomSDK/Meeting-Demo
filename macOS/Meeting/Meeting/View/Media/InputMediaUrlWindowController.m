//
//  InputMediaUrlWindowController.m
//  MeetingTestDemo_MAC
//
//  Created by YunWu01 on 2021/12/15.
//

#import "InputMediaUrlWindowController.h"

@interface InputMediaUrlWindowController ()
@property (weak) IBOutlet NSTextField *inputTextField;

@end

@implementation InputMediaUrlWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)startPlay:(id)sender {
    if (_inputTextField.stringValue.length > 0) {
        //停止之前播放
        [[CloudroomVideoMeeting shareInstance] stopPlayMedia];
        [[CloudroomVideoMeeting shareInstance] startPlayMedia:_inputTextField.stringValue bLocPlay:NO bPauseWhenFinished:NO];
        
        if (_openMediaUrlBlock) {
            _openMediaUrlBlock();
        }
        
        [self close];
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSAlertStyleWarning;
        alert.messageText = @"请先输入播放地址";
        [alert addButtonWithTitle:@"确定"];
        
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            
        }];
    }
}

@end
