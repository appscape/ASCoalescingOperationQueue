#import "ASCoalescingOperationQueue.h"

@implementation ASCoalescingOperationQueue {
    dispatch_queue_t executionQueue;
    
    // Access to nextUpBlock is synchronized through nextUpQueue
    dispatch_queue_t nextUpQueue;
    dispatch_block_t nextUpBlock;
}


+ (id)coalescingOperationQueue {
    return [[self alloc] init];
}

- (id)init {
    if (!(self = [super init]))
        return nil;
    
    executionQueue = dispatch_queue_create("at.appscape.ASCoalescingOperationQueue.executionQueue", DISPATCH_QUEUE_SERIAL);
    if (!executionQueue) return nil;
    
    nextUpQueue = dispatch_queue_create("at.appscape.ASCoalescingOperationQueue.nextUpQueue", DISPATCH_QUEUE_SERIAL);
    if (!nextUpQueue) { dispatch_release(executionQueue); return nil; }
    
    dispatch_sync(nextUpQueue, ^{
        nextUpBlock = nil;
    });
    
    return self;
}

- (void)dealloc {
    dispatch_release(nextUpQueue);
    dispatch_release(executionQueue);
}

- (void)performBlock:(dispatch_block_t)submittedBlock {
    dispatch_async(nextUpQueue, ^{
        dispatch_block_t previouslySubmittedBlock = nextUpBlock;
        nextUpBlock = submittedBlock;
        if (!previouslySubmittedBlock) {
            dispatch_async(executionQueue, ^{
                __block dispatch_block_t blockToExecute = nil;
                dispatch_sync(nextUpQueue, ^{
                    blockToExecute = nextUpBlock;
                    nextUpBlock = nil;
                });
                if (blockToExecute)
                    blockToExecute();
            });
        }
    });
}

@end
