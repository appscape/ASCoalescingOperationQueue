#import <Foundation/Foundation.h>

@interface ASCoalescingOperationQueue : NSObject

+ (id)coalescingOperationQueue;

- (void)performBlock:(dispatch_block_t)block;

@end
