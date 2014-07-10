//
//  Q2D.m
//  Q2D
//
//  Created by Justin Poliachik on 7/10/14.
//
//

#import "Q2D.h"
#import "Q2DSubqueue.h"

//
//@interface NSMutableArray (QueueAdditions)
//- (id) dequeue;
//- (void) enqueue:(id)obj;
//@end
//
//@implementation NSMutableArray (QueueAdditions)
//// Queues are first-in-first-out, so we remove objects from the head
//- (id) dequeue {
//	if ([self count] == 0) return nil;
//    id headObject = [self objectAtIndex:0];
//    if (headObject != nil) {
//        [self removeObjectAtIndex:0];
//    }
//    return headObject;
//}
//
//// Add to the tail of the queue (no one likes it when people cut in line!)
//- (void) enqueue:(id)anObject {
//    [self addObject:anObject];
//    //this method automatically adds to the end of the array
//}
//@end

@interface Q2D()
@property (strong, nonatomic) NSMutableOrderedSet *mainQueue;
@end


@implementation Q2D

const static NSString *kNameKey = @"name";
const static NSString *kQueueKey = @"queue";

- (id)init
{
	self = [super init];
	if(self){
		self.mainQueue = [NSMutableOrderedSet orderedSet];
	}
	return self;
}

//Will return a subqueue if it exists in the main queue.
//Will return nil if not found.
- (Q2DSubqueue *)getSubqueueNamed:(NSString *)name
{
	NSUInteger index = [self.mainQueue indexOfObject:name];
	if(index != NSNotFound){
		return [self.mainQueue objectAtIndex:index];
	}else{
		return nil;
	}
}

//Will always return a subqueue
//Either one that already exists in the queue,
//Or will create a new one.
- (Q2DSubqueue *)subqueueWithName:(NSString *)name
{
	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
	if(!subqueue){
		//Create a new subqueue
		subqueue = [self addSubqueueWithName:name];
	}
	
	return subqueue;
}

- (Q2DSubqueue *)addSubqueueWithName:(NSString *)name
{
	Q2DSubqueue *newQueue = [[Q2DSubqueue alloc] initWithName:name];
	
	[self.mainQueue addObject:newQueue];
	
	//Send message so the delegate knows the subqueue was added to the main queue and is awaiting download.
	if([self.delegate respondsToSelector:@selector(subqueueWasAdded:)]){
		[self.delegate subqueueDidBegin:name];
	}
	
	return newQueue;
}

- (void)removeSubqueueWithName:(NSString *)name asCompleted:(BOOL)asCompleted
{
	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
	if(subqueue){
		//Remove from main queue
		[self.mainQueue removeObject:subqueue];
		
		//Send delegate messages
		if([self.delegate respondsToSelector:@selector(subqueueWasRemoved:)]){
			[self.delegate subqueueWasRemoved:name];
		}
		
		if(asCompleted && [self.delegate respondsToSelector:@selector(subqueueDidComplete:)]){
			[self.delegate subqueueDidComplete:name];
		}
		
		if(self.mainQueue.count == 0 && [self.delegate respondsToSelector:@selector(queueDidComplete)]){
			[self.delegate queueDidComplete];
		}
	}
}

- (void)moveSubqueueToTop:(NSString *)name
{
	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
	if(subqueue && [self.mainQueue firstObject] != name){
		NSUInteger indexOfObject = [self.mainQueue indexOfObject:subqueue];
		[self.mainQueue moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:indexOfObject] toIndex:0];
	}
}

- (void)moveSubqueueToBottom:(NSString *)name
{
	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
	if(subqueue && [self.mainQueue lastObject] != name){
		NSUInteger indexOfObject = [self.mainQueue indexOfObject:subqueue];
		[self.mainQueue moveObjectsAtIndexes:[NSIndexSet indexSetWithIndex:indexOfObject] toIndex:self.mainQueue.count - 1];
	}
}

- (void)enqueueObject:(id)object toSubqueueWithName:(NSString *)name
{
	if(object){
		//Get or create the subqueue.
		Q2DSubqueue *subqueue = [self subqueueWithName:name];
		
		if(![subqueue containsObject:object]){
			[subqueue enqueue:object];
		}
	}
}

- (id)dequeueFromSubqueueWithName:(NSString *)name
{
	Q2DSubqueue *subqueue = [self getSubqueueNamed:name];
	if(subqueue){
		
		id object = [subqueue dequeue];
		
		if([subqueue count] == 0){
			[self removeSubqueueWithName:name asCompleted:YES];
		}
		
		return object;
	}else{
		return nil;
	}
}

//Returns the object at the top of the queue, but does not dequeue it.
- (id)peek
{
	if(self.mainQueue.count > 0){
		
		Q2DSubqueue *subqueue = [self.mainQueue firstObject];
		return [subqueue peek];

	}else{
		//Return nil if there are no subqueues
		return nil;
	}
}

- (id)dequeue
{
	//Dequeue the object from the queue at the top
	if(self.mainQueue.count > 0){
		
		Q2DSubqueue *subqueue = [self.mainQueue firstObject];
		return [self dequeueFromSubqueueWithName:subqueue.name];
		
	}else{
		
		//Return nil if there are no subqueues
		return nil;
	}
}

@end
