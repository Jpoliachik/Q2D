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


















//
////Will return a subqueue if it exists in the main queue.
////Will return nil if not found.
//- (Q2DSubqueue *)getSubqueueNamed:(NSString *)name
//{
//	NSUInteger index = [self.mainQueue indexOfObject:name];
//	if(index != NSNotFound){
//		return [self.mainQueue objectAtIndex:index];
//	}else{
//		return nil;
//	}
//}
//
////Will always return a subqueue
////Either one that already exists in the queue,
////Or will create a new one.
//- (Q2DSubqueue *)subqueueWithName:(NSString *)name
//{
//	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
//	if(!subqueue){
//		//Create a new subqueue
//		subqueue = [self addSubqueueWithName:name];
//	}
//	
//	return subqueue;
//}
//
//- (Q2DSubqueue *)addSubqueueWithName:(NSString *)name
//{
//	Q2DSubqueue *newQueue = [[Q2DSubqueue alloc] initWithName:name];
//	
//	[self.mainQueue addObject:newQueue];
//	
//	//Send message so the delegate knows the subqueue was added to the main queue and is awaiting download.
//	if([self.delegate respondsToSelector:@selector(subqueueWasAdded:)]){
//		[self.delegate subqueueDidBegin:name];
//	}
//	
//	return newQueue;
//}
//
//- (void)removeSubqueueWithName:(NSString *)name asCompleted:(BOOL)asCompleted
//{
//	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
//	if(subqueue){
//		//Remove from main queue
//		[self.mainQueue removeObject:subqueue];
//		
//		//Send delegate messages
//		if([self.delegate respondsToSelector:@selector(subqueueWasRemoved:)]){
//			[self.delegate subqueueWasRemoved:name];
//		}
//		
//		if(asCompleted && [self.delegate respondsToSelector:@selector(subqueueDidComplete:)]){
//			[self.delegate subqueueDidComplete:name];
//		}
//		
//		if(self.mainQueue.count == 0 && [self.delegate respondsToSelector:@selector(queueDidComplete)]){
//			[self.delegate queueDidComplete];
//		}
//	}
//}
//
//- (void)moveSubqueueToTop:(NSString *)name
//{
//	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
//	if(subqueue && [self.mainQueue firstObject] != name){
//		NSUInteger indexOfObject = [self.mainQueue indexOfObject:subqueue];
//		[self.mainQueue moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:indexOfObject] toIndex:0];
//	}
//}
//
//- (void)moveSubqueueToBottom:(NSString *)name
//{
//	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
//	if(subqueue && [self.mainQueue lastObject] != name){
//		NSUInteger indexOfObject = [self.mainQueue indexOfObject:subqueue];
//		[self.mainQueue moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:indexOfObject] toIndex:self.mainQueue.count - 1];
//	}
//}
//
//- (void)enqueueObject:(id)object toSubqueueWithName:(NSString *)name
//{
//	if(object){
//		//Get or create the subqueue.
//		Q2DSubqueue *subqueue = [self subqueueWithName:name];
//		
//		if(![subqueue containsObject:object]){
//			[subqueue enqueue:object];
//		}
//	}
//}
//
//- (id)dequeueFromSubqueueWithName:(NSString *)name
//{
//	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
//	if(subqueue){
//		
//		id object = [subqueue dequeue];
//		
//		if([subqueue count] == 0){
//			[self removeSubqueueWithName:name asCompleted:YES];
//		}
//		
//		return object;
//	}else{
//		return nil;
//	}
//}
//
////Returns the object at the top of the queue, but does not dequeue it.
//- (id)peek
//{
//	if(self.mainQueue.count > 0){
//		
//		Q2DSubqueue *subqueue = [self.mainQueue firstObject];
//		return [subqueue peek];
//
//	}else{
//		//Return nil if there are no subqueues
//		return nil;
//	}
//}
//
//- (id)dequeue
//{
//	//Dequeue the object from the queue at the top
//	if(self.mainQueue.count > 0){
//		
//		Q2DSubqueue *subqueue = [self.mainQueue firstObject];
//		return [self dequeueFromSubqueueWithName:subqueue.name];
//		
//	}else{
//		
//		//Return nil if there are no subqueues
//		return nil;
//	}
//}

@end
