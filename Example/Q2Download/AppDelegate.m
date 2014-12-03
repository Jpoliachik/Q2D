//
//  AppDelegate.m
//  Q2Download
//
//  Created by Justin Poliachik on 7/10/14.
//  Copyright (c) 2014 justinpoliachik. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    // sample test use
    
    Q2D *queue = [[Q2D alloc] init];
    queue.startsAutomatically = NO;
    
    queue.delegate = self;
    
    // create 5 subqueues
    // 6 NSOperations within each subqueue
    
    for (int i = 0; i < 50; i++) {
        
        for (int j = 0; j < 40; j++) {
            
            NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
                
                NSLog(@"Block Operation %d in subqueue %d Started", j, i);
                for ( int k = 0; k < 100000; k++ ) {
                    
                }
                
                NSLog(@"Block Operation %d in subqueue %d Done", j, i);
                
            }];
            
            [queue enqueueOperation:blockOperation withID:[NSString stringWithFormat:@"operation%d", j] toSubqueueWithID:[NSString stringWithFormat:@"subqueue%d", i]];
            
        }
        
        if (i == 40) {
            queue.startsAutomatically = YES;
        }

        
    }
    
    [queue setPriorityLevel:NSOperationQueuePriorityHigh forOperationWithID:@"operation10" inSubqueueID:@"subqueue20"];
    [queue setPriorityLevel:NSOperationQueuePriorityHigh forOperations:@[@"operation12", @"operation8"] inSubqueueID:@"subqueue8"];
    [queue setPriorityLevel:NSOperationQueuePriorityLow forAllOperationsInSubqueueID:@"subqueue8"];
    [queue setPriorityLevel:NSOperationQueuePriorityHigh forOperations:@[@"operation5", @"operation35"] inSubqueueID:@"subqueue31"];
    
    
    BOOL contains = [queue containsOperationWithID:@"operation9" inSubqueueWithID:@"subqueue2"];
    NSLog(@"CONTAINS %d", contains);
    
    [queue pause];
    [queue printContentsOfQueue];
    NSLog(@"CONTENTS DESCRIPTION: %@", [queue contentsDescription]);
    [queue resume];
    
    // test
    [queue cancelSubqueueWithID:@"subqueue0"];
    
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)queueDidComplete
{
    NSLog(@"Queue Did Complete");
}

- (void)subqueueWasCancelled:(NSString *)name
{
    NSLog(@"Subqueue was cancelled %@", name);
}

- (void)subqueueWasAdded:(NSString *)name
{
    NSLog(@"Subqueue was added %@", name);
}

- (void)subqueueDidComplete:(NSString *)name
{
    NSLog(@"Subqueue did complete %@", name);
}

- (void)subqueueDidBegin:(NSString *)name
{
    NSLog(@"Subqueue did begin %@", name);
}

@end
