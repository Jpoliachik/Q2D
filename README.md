Q2D
===

A two-dimensional serial queue for NSOperations that supports quick and easy reordering,
prioritization, and cancellation of subqueues and processes while the queue is processing.

## What to use Q2D for

- Long running processes that need to execute serially, which can be grouped
  into subcategories and may require reordering or modification after being added
  to the queue.

    - Example: downloading large files for several different sections of the app.

      Q2D can queue up all the downloads. Then based on user interaction, certain downloads
      can be prioritized over others.

Q2D currently only supports serial execution.

## Usage

Import `Q2D.h`

##### Init
``` Q2D *queue = [[Q2D alloc] init];```


##### Adding NSOperations
```objective-c
NSOperation *myOperation = [[NSOperation alloc] init];
[queue enqueueOperation:myOperation withID:@"myUniqueOperationID" toSubqueueWithID:@"mySubqueueID"];

// or

[queue enqueueOperationWithBlock:^{
    // perform tasks
}withID:@"otherUniqueOperationID" toSubqueueWithID:@"otherSubqueueID"];
```
Q2D will automatically start executing once NSOperations have been added

##### Subqueue and Operation management
```objective-c
[queue prioritizeSubqueueWithID:@"mySubqueueID"];
[queue cancelSubqueueWithID:@"mySubqueueID"];

[queue setPriorityLevel:NSOperationQueuePriorityHigh forOperationWithID:@"myUniqueOperationID" inSubqueueID:@"mySubqueueID"];
[queue cancelOperationWithID:@"myUniqueOperationID" inSubqueueWithID:@"mySubqueueID"];
```
Prioritization and cancellation can be performed at any time

### Q2DDelegate

Callback methods to provide queue execution updates
```objective-c
- (void)subqueueWasAdded:(NSString *)name;
- (void)subqueueWasCancelled:(NSString *)name;
- (void)subqueueDidBegin:(NSString *)name;
- (void)subqueueDidComplete:(NSString *)name;
- (void)queueDidComplete;
```
**Note**: Q2DDelegate methods are not to be relied upon. Messages could be sent more than once per subqueue, especially
during reordering or late enqueueing. They are meant to be used as simple updates on the status of the
queue.
