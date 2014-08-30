//
//  Q2DOperationQueue.m
//  
//
//  Created by Justin Poliachik on 8/30/14.
//
//

#import "Q2DOperationQueue.h"

@interface Q2DOperationQueue()
@property (nonatomic, strong) NSMutableDictionary *hashTable;
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


- (void)addOperation:(NSOperation *)operation withID:(NSString *)operationID
{
    if (![operationID length]) {
        return;
    }
    
    if (!operation) {
        return;
    }
    
    NSString *operationIdCopy = [operationID copy];
    __weak NSOperation *weakOp = operation;
    
    void (^realCompletionBlock)() = operation.completionBlock;
    operation.completionBlock = ^{
        @synchronized(self) {
            // Make sure we are removing the right object, because
            // if the op was cancelled and it was replaced, we
            // don't want to remove the op that replaced it
            NSOperation *opInQueue = [self.hashTable objectForKey:operationID];
            if (weakOp == opInQueue) {
                [self.hashTable removeObjectForKey:operationIdCopy];
            }
        }
        if (realCompletionBlock) {
            realCompletionBlock();
        }
    };
    
    @synchronized(self) {
        NSOperation *opInQueue = [self.hashTable objectForKey:operationID];
        
        // If the op isn't already in the queue or if there is one in the queue
        // but it is cancelled, we'll let another one in.
        if (!opInQueue || opInQueue.isCancelled) {
            self.hashTable[operationIdCopy] = operation;
//            [self.hashTable setValue:operation forKey:operationIdCopy];
            
            [super addOperation:operation];
        }
    }
}

- (void)addOperationWithBlock:(void (^)(void))block withID:(NSString *)aID
{
    [self addOperation:[NSBlockOperation blockOperationWithBlock:block] withID:aID];
}

- (void)cancelOperationWithID:(NSString *)anID
{
    @synchronized(self) {
        NSOperation *op = [self.hashTable objectForKey:anID];
        [op cancel];
    }
}

- (NSOperation *)operationWithID:(NSString *)anID {
    @synchronized(self) {
        NSOperation *op = [self.hashTable objectForKey:anID];
        return op;
    }
}

- (void)setQueuePriority:(NSOperationQueuePriority)priority forID:(NSString *)theID
{
    @synchronized(self) {
        
        NSOperation *existingOperation = [self.hashTable objectForKey:theID];
        
        if (![existingOperation isExecuting] && existingOperation.queuePriority != priority) {
            
            [existingOperation setQueuePriority:priority];
        }
    }
}
- (void)addOrSetQueuePriority:(NSOperationQueuePriority)priority operation:(NSOperation *)op withID:(NSString *)anID
{
    @synchronized(self) {
        NSOperation *existingOperation = [self.hashTable objectForKey:anID];
        if (existingOperation) {
            if ([existingOperation isExecuting]) {
                // do nothing, too late to change priority
            }
            else if (existingOperation.queuePriority == priority) {
                // do nothing, priority has not changed
            }
            else {
                // http://developer.apple.com/library/mac/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationObjects/OperationObjects.html#//apple_ref/doc/uid/TP40008091-CH101-SW38 says to never modify an operation once placed in a queue, so if it has not yet started, cancel and add the same operation but with a new priority.
                [existingOperation cancel];
                [op setQueuePriority:priority];
                [self addOperation:op withID:anID];
            }
        }
        else {
            [op setQueuePriority:priority];
            [self addOperation:op withID:anID];
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
