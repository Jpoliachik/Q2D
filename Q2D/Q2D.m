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
@end


@implementation Q2D

- (id)init
{
	self = [super init];
	if(self){
		self.mainQueue = [NSMutableOrderedSet orderedSet];
        self.defaultMaxConcurrentOperations = 1;
	}
	return self;
}

#pragma mark - Public Methods

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
        }
        
        [self checkQueuesAndStartIfNeeded];

    }
    
}

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
            
            [self checkQueuesAndStartIfNeeded];
        }
        
    }
}

- (void)setPriorityLevel:(NSOperationQueuePriority)priority forOperationWithID:(NSString *)operationID inSubqueueID:(NSString *)subqueueID
{
    @synchronized(self) {
        
        if (!priority || !operationID || !subqueueID) {
            return;
        }
        
        Q2DOperationQueue *subqueue = [self subqueueWithID:subqueueID];
        if (subqueue) {
            [subqueue setQueuePriority:priority forID:operationID];
        }
        
    }
}

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
            
            // new top queue. start the operations.
            [topQueue setSuspended:NO];
            
            if ( [self.delegate respondsToSelector:@selector(subqueueDidBegin:)] ) {
                [self.delegate subqueueDidBegin:topQueue.name];
            }
        }
    }
}

- (void)removeSubqueue:(Q2DOperationQueue *)subqueue asCompleted:(BOOL)completed
{
    [subqueue cancelAllOperations];
    [self.mainQueue removeObject:subqueue];
    
    // post delegate message
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
