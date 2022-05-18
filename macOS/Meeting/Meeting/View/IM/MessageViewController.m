//
//  MessageViewController.m
//  Meeting
//
//  Created by YunWu01 on 2021/11/9.
//

#import "MessageViewController.h"
#import "MessageCellView.h"

@interface MessageViewController () <NSTabViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSTextField *textField;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.tableView registerNib:[[NSNib alloc] initWithNibNamed:@"MessageCellView" bundle:nil] forIdentifier:@"MessageCellView"];
}

- (void)reloadTableView {
    [self.tableView reloadData];
}

- (void)clearTextField {
    self.textField.stringValue = [NSString new];
}

- (IBAction)sendMessageAction:(id)sender {
    if (_textFieldShouldReturn) {
        _textFieldShouldReturn(self.textField.stringValue);
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.messages.count;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    MChatModel *chatModel = [self.messages objectAtIndex:row];

    MessageCellView *cellView = [tableView makeViewWithIdentifier:@"MessageCellView" owner:nil];
    cellView.messageLabel.stringValue = chatModel.content.length > 0 ? [NSString stringWithFormat:@"[%@]\n%@", chatModel.name, chatModel.content] : [NSString new];
    return cellView;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    MChatModel *model = [self.messages objectAtIndex:row];

    if (model.cacheH == 0) {
        model.cacheH = [MessageCellView heightForModel:model maxWidth:self.view.frame.size.width font:[NSFont systemFontOfSize:13]] + 5*2;
    }
    return model.cacheH;
}

@end
