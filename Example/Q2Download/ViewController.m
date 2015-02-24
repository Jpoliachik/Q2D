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
    
    
//    BOOL contains = [queue containsOperationWithID:@"operation9" inSubqueueWithID:@"subqueue2"];
//    NSLog(@"CONTAINS %d", contains);
//    
//    [queue pause];
//    [queue printContentsOfQueue];
//    NSLog(@"CONTENTS DESCRIPTION: %@", [queue contentsDescription]);
//    [queue resume];
//    
//    // test
//    [queue cancelSubqueueWithID:@"subqueue0"];

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
