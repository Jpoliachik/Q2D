//
//  Q2D.h
//  Q2D
//
//  Created by Justin Poliachik on 7/10/14.
//
//

#import <Foundation/Foundation.h>

/**
 *  Q2Delegate Protocol
 *
 *  Q2D will send delegate messages as updates to what is currently being executed
 *
 *  Note: Delegate messages could be sent more than once per subqueue, especially
 *  during reordering or late enqueueing
 */
@protocol Q2DDelegate <NSObject>
@optional
- (void)subqueueWasAdded:(NSString *)name;
- (void)subqueueWasCancelled:(NSString *)name;
- (void)subqueueDidBegin:(NSString *)name;
- (void)subqueueDidComplete:(NSString *)name;
- (void)queueDidComplete;
@end

/**
 *  Q2D
 *
 *  Two-dimensional queue that allows quick lookup and reordering of subqueues
 *  Useful for timely operations in groups that need reordering and modification during
 *  queue execution time.
 *
 *  Uses a NSMutableOrderedSet to create a queue of unique NSOperationQueue objects.
 *  
 *  Subqueues are required to have a unique ID
 *  NSOperations are required to have a unique ID within its subqueue
 */
@interface Q2D : NSObject

@property (nonatomic, weak) id<Q2DDelegate> delegate;

/**
 *  enqueueOperation
 *  Adds the NSOperation to Q2D in the correct subqueue
 *
 *  @param operation   NSOperation to be added to Q2D
 *  @param operationID required unique (within its subqueue) ID for the NSOperation
 *  @param subqueueID  required unique ID for the subqueue
 */
- (void)enqueueOperation:(NSOperation *)operation withID:(NSString *)operationID toSubqueueWithID:(NSString *)subqueueID;



/**
 *  prioritizeSubqueueWithID
 *  if a subqueue with the ID is found, it will be moved to position 0 in the main queue
 *  the currently running Q2DOperationQueue will complete the currently executing NSOperation, then suspend itself
 *  the newly prioritized subqueue will begin executings
 *
 *  @param subqueueID ID of the subqueue to be prioritized
 */
- (void)prioritizeSubqueueWithID:(NSString *)subqueueID;


/**
 *  setPriorityLevel
 *  sets the NSOperation's queuePriorityLevel
 *  if the NSOperation or subqueue are not found, nothing happens
 *
 *  @param priority    NSOperationQueuePriorityLevel
 *  @param operationID ID of the NSOperation to set the priority level
 *  @param subqueueID  ID of the subqueue containing the NSOperation
 */
- (void)setPriorityLevel:(NSOperationQueuePriority)priority forOperationWithID:(NSString *)operationID inSubqueueID:(NSString *)subqueueID;


/**
 *  cancelOperationWithID
 *  cancels a single NSOperation
 *  if the NSOperation or subqueue are not found, nothing happens
 *
 *  @param operationID ID of the NSOperation to cancel
 *  @param subqueueID  ID of the subqueue containg the NSOperation
 */
- (void)cancelOperationWithID:(NSString *)operationID inSubqueueWithID:(NSString *)subqueueID;


/**
 *  cancelSubqueueWithId
 *  cancels all NSOperations within a subqueue, then removes
 *  the subqueue from the main queue. 
 *  if a NSOperation is currently executing within the cancelled subqueue, it will
 *  continue until completion based on the NSOperation implementation. 
 *
 *  @param subqueueID ID of the subqueue to cancel
 */
- (void)cancelSubqueueWithID:(NSString *)subqueueID;


@end
