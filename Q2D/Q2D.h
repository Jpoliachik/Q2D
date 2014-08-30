//
//  Q2D.h
//  Q2D
//
//  Created by Justin Poliachik on 7/10/14.
//
//

#import <Foundation/Foundation.h>

@protocol Q2DDelegate <NSObject>
@optional
- (void)subqueueWasAdded:(NSString *)name;
- (void)subqueueWasRemoved:(NSString *)name;
- (void)subqueueDidBegin:(NSString *)name;
- (void)subqueueDidComplete:(NSString *)name;
- (void)queueDidComplete;
@end


@interface Q2D : NSObject

@property (nonatomic, weak) id<Q2DDelegate> delegate;

- (void)enqueueOperation:(NSOperation *)operation withID:(NSString *)operationID toSubqueueWithID:(NSString *)subqueueID;
- (void)prioritizeSubqueueWithID:(NSString *)subqueueID;
- (void)setPriorityLevel:(NSOperationQueuePriority)priority forOperationWithID:(NSString *)operationID inSubqueueID:(NSString *)subqueueID;
- (void)cancelOperationWithID:(NSString *)operationID inSubqueueWithID:(NSString *)subqueueID;
- (void)cancelSubqueueWithID:(NSString *)subqueueID;


@end
