//
//  MemberViewController.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/9.
//

#import "MemberViewController.h"
#import "MemberCellView.h"
#import "EditNicknameWindowController.h"

@interface MemberViewController () <NSTabViewDelegate, NSTableViewDataSource, NSMenuDelegate>
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) EditNicknameWindowController *editNicknameWindow;
@property (strong) IBOutlet NSMenu *memberMenu;

@end

@implementation MemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"MemberCellView" bundle:nil] forIdentifier:@"MemberCellView"];
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (IBAction)menuAction1:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row == -1) return;
    
    MemberInfo *member = [self.members objectAtIndex:row];
    NSString *myUserId = [[CloudroomVideoMeeting shareInstance] getMyUserID];
    if (![myUserId isEqualToString:member.userId]) {
        [[CloudroomVideoMeeting shareInstance] kickout:member.userId];
    }
}
- (IBAction)menuAction2:(id)sender {
    NSInteger row = [self.tableView clickedRow];
    if (row == -1) return;
    
    _editNicknameWindow = [[EditNicknameWindowController alloc] initWithWindowNibName:@"EditNicknameWindowController"];
    [_editNicknameWindow.window center];
    [_editNicknameWindow.window orderFront:nil];
    
    __weak typeof(self) weakSelf = self;
    [_editNicknameWindow setEditNicknameBlock:^(NSString * _Nonnull nickname) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        MemberInfo *member = [strongSelf.members objectAtIndex:row];
        [[CloudroomVideoMeeting shareInstance] setNickName:member.userId nickName:nickname];
    }];
}
- (IBAction)menuAction3:(id)sender {
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu {
    [menu removeAllItems];
    
    NSInteger index = self.tableView.clickedRow;
    if (index < 0) {
        return;
    }
    
    MemberInfo *member = [self.members objectAtIndex:index];
    NSString *myUserId = [[CloudroomVideoMeeting shareInstance] getMyUserID];
    if (![myUserId isEqualToString:member.userId]) {
        [menu addItemWithTitle:@"踢人" action:@selector(menuAction1:) keyEquivalent:@""];
    }
    [menu addItemWithTitle:@"修改昵称" action:@selector(menuAction2:) keyEquivalent:@""];
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.members.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    MemberInfo *member = [self.members objectAtIndex:row];
    
    MemberCellView *cellView = [tableView makeViewWithIdentifier:@"MemberCellView" owner:nil];
    cellView.member = member;
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    return 30;
}

@end
