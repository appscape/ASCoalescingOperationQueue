#import <Foundation/Foundation.h>

@interface ASCoalescingOperationQueue : NSObject

+ (id)coalescingOperationQueue;
+ (id)coalescingOperationQueueUsingMainQueue;
+ (id)coalescingOperationQueueUsingQueue:(dispatch_queue_t)theQueue; // retains theQueue

- (void)performBlock:(dispatch_block_t)block;

@end
