//
//  Q2DSubqueue.m
//  
//
//  Created by Justin Poliachik on 7/10/14.
//
//

#import "Q2DSubqueue.h"

@interface Q2DSubqueue()
@property (nonatomic, strong) NSMutableArray *queue;
@end

@implementation Q2DSubqueue

#pragma mark - Init

- (instancetype)initWithName:(NSString *)name
{
	if(!name){
		return nil;
	}
	
	self = [super init];
	if(self){
		self.queue = [NSMutableArray array];
		self.name = name;
	}
	return self;
}

#pragma mark - Public Methods

- (BOOL)containsObject:(id)object
{
	return [self.queue containsObject:object];
}

- (void)enqueue:(id)object
{
	[self.queue addObject:object];
}

- (id)dequeue
{
	//Dequeue the object from the queue at the top
	id topObject = [self.queue firstObject];
	if(topObject){
		//Remove it from the array
		[self.queue removeObjectAtIndex:0];
	}
	
	return topObject;

}

- (id)peek
{
	return [self.queue firstObject];
}

- (NSUInteger)count
{
	return self.queue.count;
}

#pragma mark - Equality

//Equality check
//Since the subqueue names need to be unique, use the name property to determine equallity.
- (BOOL)isEqualToSubqueue:(Q2DSubqueue *)subqueue
{
	if(!subqueue){
		return NO;
	}
	
	return [self.name isEqualToString:subqueue.name];
}

- (BOOL)isEqualToSubqueueName:(NSString *)subqueueName
{
	if(!subqueueName){
		return NO;
	}
	
	return [self.name isEqualToString:subqueueName];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object
{
	if(self == object){
		return YES;
	}
	
	//If a string, test for equality based on the name.
	if([object isKindOfClass:[NSString class]]){
		return [self isEqualToSubqueueName:object];
	}
	
	if (![object isKindOfClass:[Q2DSubqueue class]]) {
		return NO;
	}
	
	return [self isEqualToSubqueue:object];
}

- (NSUInteger)hash
{
	//Hash the name string property. It will always be unique.
	return [self.name hash];
}

@end
