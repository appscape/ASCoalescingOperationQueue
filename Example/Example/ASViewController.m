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
    
    // Spawn a second "thread"
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger i = 0;
        while (true) { // Just increment i forever
            i++;
            NSLog(@"%d", i);
            
            [coalescingQueue performBlock:^{
                // Do something that takes a while with the latest value of i
                sleep(1);
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    // Add i to tableView
                    [numbers addObject:[[NSNumber numberWithInteger:i] stringValue]];
                    [self.view reloadData];
                });
            }];
            
            // Add some delay
            usleep(10000);
        }
    });
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
