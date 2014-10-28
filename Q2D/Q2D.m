//
//  Q2D.m
//  Q2D
//
//  Created by Justin Poliachik on 7/10/14.
//
//

#import "Q2D.h"
#import "Q2DOperationQueue.h"

@interface Q2D()
@property (strong, nonatomic) NSMutableOrderedSet *mainQueue;
@property (nonatomic) NSUInteger defaultMaxConcurrentOperations;
@property (nonatomic, assign) BOOL isSuspended;
@end


@implementation Q2D

- (id)init
{
	self = [super init];
	if(self){
		self.mainQueue = [NSMutableOrderedSet orderedSet];
        self.defaultMaxConcurrentOperations = 1;
        self.startsAutomatically = YES;
        self.isSuspended = NO;
	}
	return self;
}

- (void)setStartsAutomatically:(BOOL)startsAutomatically
{
    _startsAutomatically = startsAutomatically;

    if (!startsAutomatically) {
        [self pause];
    } else {
        [self resume];
    }
}

#pragma mark - Public Methods

#pragma mark - Enqueue

- (void)enqueueOperation:(NSOperation *)operation withID:(NSString *)operationID toSubqueueWithID:(NSString *)subqueueID
{
    @synchronized(self) {
        
        if (!operation || !operationID || !subqueueID) {
            return;
        }
        
        [self setOperationCompletionBlock:operation];
        
        Q2DOperationQueue *existingSubqueue = [self subqueueWithID:subqueueID];
        
        if (existingSubqueue) {
            [existingSubqueue addOperation:operation withID:operationID];
        } else {
            
            // no subqueue with that ID exists
            Q2DOperationQueue *newSubqueue = [self createSubqueueWithID:subqueueID];
            [newSubqueue addOperation:operation withID:operationID];
            
            [self.mainQueue addObject:newSubqueue];
            
            if ([self.delegate respondsToSelector:@selector(subqueueWasAdded:)]) {
                [self.delegate subqueueWasAdded:subqueueID];
            }
        }
        
        if (self.startsAutomatically) {
            [self checkQueuesAndStartIfNeeded];
        }

    }
    
}

- (void)enqueueOperationWithBlock:(void(^)())block withID:(NSString *)operationID toSubqueueWithID:(NSString *)subqueueID
{
    [self enqueueOperation:[NSBlockOperation blockOperationWithBlock:block] withID:operationID toSubqueueWithID:subqueueID];
}

#pragma mark - Prioritization

- (void)prioritizeSubqueueWithID:(NSString *)subqueueID
{
    @synchronized(self) {
        
        if (!subqueueID) {
            return;
        }
        
        Q2DOperationQueue *subqueue = [self subqueueWithID:subqueueID];
        if (subqueue) {
            
            Q2DOperationQueue *currentTopQueue = [self.mainQueue firstObject];
            if (currentTopQueue) {
                [currentTopQueue setSuspended:YES];
            }
            
            NSUInteger index = [self.mainQueue indexOfObject:subqueue];
            [self.mainQueue moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index] toIndex:0];
            
            if (self.startsAutomatically) {
                [self checkQueuesAndStartIfNeeded];
            }
        }
        
    }
}

- (void)setPriorityLevel:(NSOperationQueuePriority)priority forOperationWithID:(NSString *)operationID inSubqueueID:(NSString *)subqueueID
{
    [self setPriorityLevel:priority forOperations:@[operationID] inSubqueueID:subqueueID];
}

- (void)setPriorityLevel:(NSOperationQueuePriority)priority forOperations:(NSArray *)operationArray inSubqueueID:(NSString *)subqueueID
{
    @synchronized(self) {
        if (!priority || !operationArray || !subqueueID) {
            return;
        }
        
        Q2DOperationQueue *subqueue = [self subqueueWithID:subqueueID];
        if (subqueue) {
            
            [subqueue setQueuePriority:priority forIDs:operationArray];
        }
    }
}

- (void)setPriorityLevel:(NSOperationQueuePriority)priority forAllOperationsInSubqueueID:(NSString *)subqueueID
{
    @synchronized(self) {
        
        if (!subqueueID) {
            return;
        }
        
        Q2DOperationQueue *subqueue = [self subqueueWithID:subqueueID];
        if (subqueue) {
            
            [subqueue setAllQueuePriorities:priority];
        }
    }
}

#pragma mark - Cancellation

- (void)cancelOperationWithID:(NSString *)operationID inSubqueueWithID:(NSString *)subqueueID
{
    @synchronized(self) {
        
        if (!operationID || !subqueueID){
            return;
        }
        
        Q2DOperationQueue *subqueue = [self subqueueWithID:subqueueID];
        if (subqueue) {
            [subqueue cancelOperationWithID:operationID];
        }
    }
}

- (void)cancelSubqueueWithID:(NSString *)subqueueID
{
    @synchronized(self) {
        
        if (!subqueueID) {
            return;
        }
        
        Q2DOperationQueue *subqueue = [self subqueueWithID:subqueueID];
        if (subqueue) {
            [self removeSubqueue:subqueue asCompleted:NO];
        }
    }
}

#pragma mark - Execution

- (void)pause
{
    self.isSuspended = YES;
    
    Q2DOperationQueue *topQueue = [self.mainQueue firstObject];
    if (topQueue) {
        [topQueue setSuspended:YES];
    }
}

- (void)resume
{
    if (self.isSuspended) {
        self.isSuspended = NO;
        [self checkQueuesAndStartIfNeeded];
    }
}

#pragma mark - Inspection

- (BOOL)containsOperationWithID:(NSString *)operationID inSubqueueWithID:(NSString *)subqueueID
{
    Q2DOperationQueue *subqueue = [self subqueueWithID:subqueueID];
    
    if (!subqueue) {
        return NO;
    }
    
    return ([subqueue operationWithID:operationID] != nil);
}

- (void)printContentsOfQueue
{
    NSMutableDictionary *contents = [NSMutableDictionary new];
    for (Q2DOperationQueue *subqueue in self.mainQueue) {

        contents[subqueue.name] = subqueue.hashTable;
    }
    
    NSLog(@"Q2D Contents: %@", contents);
}

#pragma mark - Private Methods

- (void)checkQueuesAndStartIfNeeded
{
    Q2DOperationQueue *topQueue = [self.mainQueue firstObject];
    if (topQueue) {
        
        // if the queue at the top is empty, remove it
        if ( topQueue.operationCount == 0 ) {
            
            [self removeSubqueue:topQueue asCompleted:YES];
            [self checkQueuesAndStartIfNeeded];
            
        } else {
            
            if (!self.isSuspended) {
                if ( topQueue.isSuspended && [self.delegate respondsToSelector:@selector(subqueueDidBegin:)] ) {
                    [self.delegate subqueueDidBegin:topQueue.name];
                }
                
                
                // new top queue. start the operations.
                [topQueue setSuspended:NO];

            }
            
        }
    } else {
        
        if ([self.delegate respondsToSelector:@selector(queueDidComplete)]) {
            [self.delegate queueDidComplete];
        }
    }
}

- (void)removeSubqueue:(Q2DOperationQueue *)subqueue asCompleted:(BOOL)completed
{
    NSString *subqueueName = subqueue.name;
    
    [subqueue cancelAllOperations];
    [self.mainQueue removeObject:subqueue];
    
    // send delegate message
    if (completed) {
        
        if ([self.delegate respondsToSelector:@selector(subqueueDidComplete:)]) {
            [self.delegate subqueueDidComplete:subqueueName];
        }
    } else {
        
        if ([self.delegate respondsToSelector:@selector(subqueueWasCancelled:)]) {
            [self.delegate subqueueWasCancelled:subqueueName];
        }
    }
}

- (Q2DOperationQueue *)subqueueWithID:(NSString *)subqueueID
{
    BOOL exists = [self.mainQueue containsObject:subqueueID];
    if (exists) {
        return [self.mainQueue objectAtIndex:[self.mainQueue indexOfObject:subqueueID]];
    } else {
        return nil;
    }

}

- (Q2DOperationQueue *)createSubqueueWithID:(NSString *)theID
{
    Q2DOperationQueue *subqueue = [[Q2DOperationQueue alloc] init];
    subqueue.name = theID;
    subqueue.maxConcurrentOperationCount = self.defaultMaxConcurrentOperations;
    [subqueue setSuspended:YES];
    return subqueue;
}

- (void)setOperationCompletionBlock:(NSOperation *)operation
{
    @synchronized(self ) {
        
        if (operation) {
            
            void (^existingCompletionBlock)() = operation.completionBlock;
            [operation setCompletionBlock:^{
                
                // add this to the completion block to determine
                // when to start the next NSOperationQueue
                [self checkQueuesAndStartIfNeeded];
                
                if (existingCompletionBlock) {
                    existingCompletionBlock();
                }
            }];
            
        }
        
    }
}


@end
