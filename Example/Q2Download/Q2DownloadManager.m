//
//  Q2DownloadManager.m
//  Q2Download
//
//  Created by Justin Poliachik on 7/10/14.
//  Copyright (c) 2014 justinpoliachik. All rights reserved.
//

#import "Q2DownloadManager.h"

@interface Q2DownloadManager()
@property (nonatomic, strong) Q2D *queue;
@end

@implementation Q2DownloadManager

+ (Q2DownloadManager *)sharedManager
{
	static Q2DownloadManager *_sharedManager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedManager = [[Q2DownloadManager alloc] init];
		_sharedManager.queue = [[Q2D alloc] init];
		_sharedManager.queue.delegate = _sharedManager;
		
	});
	return _sharedManager;
}

#pragma mark - Q2DDelegate Methods

- (void)subqueueWasAdded:(NSString *)name
{
	
}

- (void)subqueueWasRemoved:(NSString *)name
{
	
}

- (void)subqueueDidBegin:(NSString *)name
{
	
}

- (void)subqueueDidComplete:(NSString *)name
{
	
}

- (void)queueDidComplete
{
	
}

@end
