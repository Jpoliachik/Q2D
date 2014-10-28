//
//  Q2DOperationQueue.m
//  
//
//  Created by Justin Poliachik on 8/30/14.
//
//

#import "Q2DOperationQueue.h"

@interface Q2DOperationQueue()
@property (nonatomic, strong, readwrite) NSMutableDictionary *hashTable;
@end

@implementation Q2DOperationQueue

- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _hashTable = [NSMutableDictionary dictionary];
    self.maxConcurrentOperationCount = 1;
    
    return self;
}

// modified from Matt Ronge's implementation in CTUniqueOperationQueue
//https://github.com/mronge/CTUniqueOperationQueue

- (void)addOperation:(NSOperation *)operation withID:(NSString *)theID
{
    if (!operation || !theID || theID.length < 1) {
        return;
    }
    
    NSString *operationIdCopy = [theID copy];
    __weak NSOperation *weakOperation = operation;
    
    // custom completion block to remove from hash table on completion
    void (^realCompletionBlock)() = operation.completionBlock;
    operation.completionBlock = ^{
        @synchronized(self) {
            // Make sure we are removing the right object, because
            // if the op was cancelled and it was replaced, we
            // don't want to remove the op that replaced it
            NSOperation *opInQueue = [self.hashTable objectForKey:theID];
            if (weakOperation == opInQueue) {
                [self.hashTable removeObjectForKey:operationIdCopy];
            }
        }
        if (realCompletionBlock) {
            realCompletionBlock();
        }
    };
    
    // add to hash table
    @synchronized(self) {
        NSOperation *operationInQueue = [self.hashTable objectForKey:theID];
        
        // If the op isn't already in the queue or if there is one in the queue
        // but it is cancelled, we'll let another one in.
        if (!operationInQueue || operationInQueue.isCancelled) {
            self.hashTable[operationIdCopy] = operation;
            
            [super addOperation:operation];
        }
    }
}

- (void)cancelOperationWithID:(NSString *)theID
{
    @synchronized(self) {
        
        NSOperation *op = [self.hashTable objectForKey:theID];
        [op cancel];
    }
}

- (NSOperation *)operationWithID:(NSString *)theID
{
    @synchronized(self) {
        
        NSOperation *op = [self.hashTable objectForKey:theID];
        return op;
    }
}

- (void)setQueuePriority:(NSOperationQueuePriority)priority forIDs:(NSArray *)operationIDs
{
    @synchronized(self) {
        
        for (NSString *opID in operationIDs) {
            
            if (![opID isKindOfClass:[NSString class]]) {
                continue;
            }
            
            NSOperation *existingOperation = [self.hashTable objectForKey:opID];
            
            if (![existingOperation isExecuting] && existingOperation.queuePriority != priority) {
                
                [existingOperation setQueuePriority:priority];
            }
        }
    }
}

- (void)setAllQueuePriorities:(NSOperationQueuePriority)priority
{
    @synchronized(self) {
        
        for (NSOperation *op in self.operations) {
            
            if (![op isExecuting] && op.queuePriority != priority) {
                [op setQueuePriority:priority];
            }
        }
    }
}

#pragma mark - Equality

- (BOOL)isEqualToQueue:(Q2DOperationQueue *)queue
{
    if (!queue) {
        return NO;
    }
    
    BOOL haveEqualNames = [self.name isEqualToString:queue.name];
    
    return haveEqualNames;
}

// used within Q2D to quickly lookup an operations position with indexOfObject:(NSString *)
- (BOOL)isEqualToQueueName:(NSString *)queueName
{
    if (!queueName){
        return NO;
    }
    
    return [self.name isEqualToString:queueName];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        // if a string, test for equality based on the name
        return [self isEqualToQueueName:object];
        
    } else if (![object isKindOfClass:[Q2DOperationQueue class]]) {
        
        return NO;
    }
    
    return [self isEqualToQueue:object];
}

- (NSUInteger)hash
{
    return [self.name hash];
}

@end
