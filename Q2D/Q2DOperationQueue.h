//
//  Q2DOperationQueue.h
//  
//
//  Created by Justin Poliachik on 8/30/14.
//
//

#import <Foundation/Foundation.h>

@interface Q2DOperationQueue : NSOperationQueue


/*!
 * Adds a NSOperation if there isn't already one in the queue with the specified id
 */
- (void)addOperation:(NSOperation *)op withID:(NSString *)aID;

/*!
 * Adds a block operation if there isn't already one in the queue with the specified id
 */
- (void)addOperationWithBlock:(void (^)(void))block withID:(NSString *)aID;

/*!
 * Cancels the operation, if there is one, which matches the specified id
 */
- (void)cancelOperationWithID:(NSString *)anID;

/*!
 * Provides the operation, if there is one, which matches the specified id
 */
- (NSOperation *)operationWithID:(NSString *)anID;

/*!
 * If the provided operation is in the queue, update the priority, otherwise add to the queue with this priority
 */
- (void)addOrSetQueuePriority:(NSOperationQueuePriority)priority operation:(NSOperation *)op withID:(NSString *)anID;

- (void)setQueuePriority:(NSOperationQueuePriority)priority forID:(NSString *)theID;

@end
