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

- (void)addOperation:(NSOperation *)operation withID:(NSString *)theID;
- (void)cancelOperationWithID:(NSString *)theID;
- (NSOperation *)operationWithID:(NSString *)theID;
- (void)setQueuePriority:(NSOperationQueuePriority)priority forID:(NSString *)theID;

@end
