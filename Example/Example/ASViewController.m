#import "ASViewController.h"

@implementation ASViewController {
    NSMutableArray *numbers;
    ASCoalescingOperationQueue *coalescingQueue;
}
@dynamic view;

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    numbers = [NSMutableArray array];
    coalescingQueue = [ASCoalescingOperationQueue coalescingOperationQueue];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger i = 0;
        while (true) {
            i++;
            [coalescingQueue performBlock:^{
                sleep(1);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [numbers addObject:[[NSNumber numberWithInteger:i] stringValue]];
                    [self.view reloadData];
                });
            }];
            usleep(100);
        }
    });
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return numbers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Default"];
    cell.textLabel.text = [numbers objectAtIndex:indexPath.row];
    return cell;
}

@end
