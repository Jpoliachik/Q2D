//
//  Q2DOperationQueue.h
//  
//
//  Created by Justin Poliachik on 8/30/14.
//
//

#import <Foundation/Foundation.h>

@interface Q2DOperationQueue : NSOperationQueue

- (void)addOperation:(NSOperation *)operation withID:(NSString *)theID;
- (void)cancelOperationWithID:(NSString *)theID;
- (NSOperation *)operationWithID:(NSString *)theID;
- (void)setQueuePriority:(NSOperationQueuePriority)priority forID:(NSString *)theID;

@end
