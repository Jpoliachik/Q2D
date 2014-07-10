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

#pragma mark - Queue Operations

//Add an object to the queue.
//Requires a subqueue name
- (void)enqueueObject:(id)object toSubqueueWithName:(NSString *)name;

//Remove the object from the top of the overall queue.
- (id)dequeue;

//Remove the object from the top of a specific subqueue
- (id)dequeueFromSubqueueWithName:(NSString *)name;

//Returns the object at the top of the queue, but does not remove it.
- (id)peek;

#pragma mark - Suqueue management

//Removes a subqueue
//asCompleted specifies whether or not to call the delegate method subqueueDidComplete
- (void)removeSubqueueWithName:(NSString *)name asCompleted:(BOOL)asCompleted;

//Move a subqueue to the top of the overall queue
- (void)moveSubqueueToTop:(NSString *)name;

//Move a subqueue to the bottom of the overall queue.
- (void)moveSubqueueToBottom:(NSString *)name;

@end
