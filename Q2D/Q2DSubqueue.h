//
//  Q2DSubqueue.h
//  
//
//  Created by Justin Poliachik on 7/10/14.
//
//

#import <Foundation/Foundation.h>

@interface Q2DSubqueue : NSObject

@property (nonatomic, strong) NSString *name;

- (instancetype)initWithName:(NSString *)name;

- (BOOL)containsObject:(id)object;
- (void)enqueue:(id)object;
- (id)dequeue;
- (id)peek;
- (NSUInteger)count;

@end
