//
//  Q2DOperationQueue.h
//  
//
//  Created by Justin Poliachik on 8/30/14.
//
//

#import <Foundation/Foundation.h>

/**
 *  Q2DOperationQueue - NSOperationQueue subclass
 *  Requires an ID (NSString *) for each NSOperation object
 *
 *  Allows O(1) lookup of NSOperation objects in the queue. 
 *  Prevents duplicates with a given ID.
 *  
 *  Maintains a NSMutableDictionary with references to NSOperation objects it contains
 */
@interface Q2DOperationQueue : NSOperationQueue

@property (nonatomic, strong, readonly) NSMutableDictionary *hashTable;

- (void)addOperation:(NSOperation *)operation withID:(NSString *)theID;
- (void)cancelOperationWithID:(NSString *)theID;
- (NSOperation *)operationWithID:(NSString *)theID;

// sets the priority for specific queues in this subqueue
- (void)setQueuePriority:(NSOperationQueuePriority)priority forIDs:(NSArray *)operationIDs;

// sets the priority for every queue in this subqueue
- (void)setAllQueuePriorities:(NSOperationQueuePriority)priority;

@end
