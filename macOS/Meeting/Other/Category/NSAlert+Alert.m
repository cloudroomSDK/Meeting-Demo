//
//  NSAlert+Alert.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/22.
//

#import "NSAlert+Alert.h"

@implementation NSAlert (Alert)

+ (void)alertMessage:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    alert.alertStyle = NSAlertStyleInformational;
    alert.messageText = message;
    [alert addButtonWithTitle:@"确定"];
    
    [alert runModal];
}

@end
