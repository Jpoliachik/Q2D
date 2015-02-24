//
//  ViewController.m
//  Q2Download
//
//  Created by Justin Poliachik on 2/24/15.
//  Copyright (c) 2015 justinpoliachik. All rights reserved.
//

#import "ViewController.h"
#import "Q2D.h"

@interface ViewController ()<Q2DDelegate>
@property (nonatomic, strong) Q2D *queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // sample test use
    
    self.queue = [[Q2D alloc] init];
    self.queue.startsAutomatically = NO;
    
    self.queue.delegate = self;
    
    self.queue.maxConcurrentOperations = 5;
    
    // create 50 subqueues
    // 40 NSOperations within each subqueue
    
    for (int i = 0; i < 50; i++) {
        
        for (int j = 0; j < 40; j++) {
            
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                
                NSLog(@"Block Operation %d in subqueue %d Started", j, i);
                for ( int k = 0; k < 100000; k++ ) {
                    float randNumGen = arc4random();
                }
                
                NSLog(@"Block Operation %d in subqueue %d Done", j, i);
                
            }];
            
            [self.queue enqueueOperation:blockOperation withID:[NSString stringWithFormat:@"operation%d", j] toSubqueueWithID:[NSString stringWithFormat:@"subqueue%d", i]];
            
        }
    }
    
    [self.queue prioritizeSubqueueWithID:@"subqueue33"];
    [self.queue setPriorityLevel:NSOperationQueuePriorityHigh forOperations:@[@"operation5", @"operation35"] inSubqueueID:@"subqueue33"];

    
    [self.queue setPriorityLevel:NSOperationQueuePriorityHigh forOperationWithID:@"operation10" inSubqueueID:@"subqueue20"];
    [self.queue setPriorityLevel:NSOperationQueuePriorityHigh forOperations:@[@"operation12", @"operation8"] inSubqueueID:@"subqueue8"];
    [self.queue setPriorityLevel:NSOperationQueuePriorityLow forAllOperationsInSubqueueID:@"subqueue8"];
    
    
    BOOL contains = [self.queue containsOperationWithID:@"operation9" inSubqueueWithID:@"subqueue2"];
    NSLog(@"CONTAINS %d", contains);
    
    [self.queue pause];
    [self.queue printContentsOfQueue];
    NSLog(@"CONTENTS DESCRIPTION: %@", [self.queue contentsDescription]);
    [self.queue resume];
    
    // test
    [self.queue cancelSubqueueWithID:@"subqueue0"];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onStart:(id)sender {
    [self.queue resume];
}

- (IBAction)onStop:(id)sender {
    [self.queue pause];
}

#pragma mark - Q2DDelegate

- (void)subqueueWasAdded:(NSString *)name {
    NSLog(@"Q2DDELEGATE SUBQUEUE WAS ADDED %@", name);
}

- (void)subqueueWasCancelled:(NSString *)name {
    NSLog(@"Q2DDELEGATE SUBQUEUE WAS CANCELLED %@", name);
}

- (void)subqueueDidBegin:(NSString *)name {
    NSLog(@"Q2DDELEGATE SUBQUEUE BEGAN %@", name);
}

- (void)subqueueDidComplete:(NSString *)name {
    NSLog(@"Q2DDELEGATE SUBQUEUE COMPLETED %@", name);
}

- (void)queueDidComplete {
    NSLog(@"Q2DDELEGATE COMPLETED");
}


@end
