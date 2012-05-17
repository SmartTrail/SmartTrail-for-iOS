//
//  BMAController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAController.h"
#import "AppDelegate.h"
#import "AreaWebClient.h"
#import "TrailWebClient.h"
#import "ConditionWebClient.h"
#import "EventWebClient.h"
#import "Area.h"
#import "NSObject+Utils.h"

static const NSTimeInterval TrailInfoInterval = 86400.0;    // Once a day.
static const NSTimeInterval ConditionInterval = 600.0;      // Every 10 min.
static const NSTimeInterval EventInterval = 3600.0;         // Every hour.
static const NSTimeInterval RecentEnoughInterval = 180.0;   // Three min.
static const NSTimeInterval ConditionLifeSpan = 2419200.0;  // Four weeks.

static dispatch_queue_t getQ();
void deleteObjects(
    CoreDataUtils* utils, NSString* templateName, NSTimeInterval age
);
static void rescheduleTimerToNext( NSTimer* timer, NSTimeInterval anInterval );

@interface BMAController ()
@property (readwrite,retain,nonatomic) NSDate* serverTimeEstimate;
@property (retain,nonatomic) NSTimer* eventDownloadTimer;
@property (retain,nonatomic) NSTimer* conditionDownloadTimer;
- (void) aNetActivityDidStart;
- (void) aNetActivityDidStop;
- (NSDate*) serverTimeEstimate;
- (void) setServerTimeEstimate:(NSDate*)now;
- (void) downloadConditionsInArea:(Area*)area;
@end


@implementation BMAController


{   //  These ivars store no reference values, so don't need to be properties.
    NSInteger __netActivitiesCount;
    NSTimeInterval __serverTimeDelta;
}
@synthesize eventDownloadTimer = __eventDownloadTimer;
@synthesize conditionDownloadTimer = __conditionDownloadTimer;


- (void) dealloc {
    [__eventDownloadTimer release];     __eventDownloadTimer = nil;
    [__conditionDownloadTimer release]; __conditionDownloadTimer = nil;
    [super dealloc];
}


- (id) init {
    self = [super init];
    if ( self ) {

        NSTimer* trailTimer = [NSTimer
            scheduledTimerWithTimeInterval:TrailInfoInterval
                                    target:self
                                  selector:@selector(downloadTrailInfo:)
                                  userInfo:nil
                                   repeats:YES
        ];
        [trailTimer fire];

        self.conditionDownloadTimer = [NSTimer
            scheduledTimerWithTimeInterval:ConditionInterval
                                    target:self
                                  selector:@selector(downloadConditions:)
                                  userInfo:nil
                                   repeats:YES
        ];
        //  No need to fire now, since conditions were downloaded w/ trail info.


        self.eventDownloadTimer = [NSTimer
            scheduledTimerWithTimeInterval:EventInterval
                                    target:self
                                  selector:@selector(downloadEvents:)
                                  userInfo:nil
                                   repeats:YES
        ];
        [self.eventDownloadTimer fire];
    }
    return  self;
}


#pragma mark - Property accessors


- (NSDate*) serverTimeEstimate {
    return [NSDate dateWithTimeIntervalSinceNow:__serverTimeDelta];
}


- (void) setServerTimeEstimate:(NSDate*)now {
    NSAssert( now, @"areaClient.serverTime is nil" );
    __serverTimeDelta =
        [now timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
}


#pragma mark - Timer handlers


- (void) downloadTrailInfo:(NSTimer*)timer {
    rescheduleTimerToNext( timer, TrailInfoInterval );
    dispatch_async( getQ(), ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithProvisions:APP_DELEGATE
        ];
        //  When an object is saved by another context between the time this
        //  context fetches the object and the time this thread attempts to save
        //  a new version of it (i.e., attempts to save a managed object with
        //  the same object id), a conflict arises. We decide here to resolve
        //  any such conflict by insisting that this context always wins. This
        //  is appropriate in this case, because, being later, this context will
        //  most likely have more recently downloaded data.
        utils.context.mergePolicy = NSOverwriteMergePolicy;

        AreaWebClient* areaClient = [[AreaWebClient  alloc]
            initWithDataUtils:utils regionId:1
        ];
        TrailWebClient* trailClient = [[TrailWebClient alloc]
            initWithDataUtils:utils regionId:1
        ];

        //
        //  Do the downloads.
        //

        [self aNetActivityDidStart];

        //  Download all areas.
        [areaClient sendSynchronousGet];
        //  Download all trails.
        if ( ! areaClient.error )  [trailClient sendSynchronousGet];
        //  Download all conditions for all trails.

        [self aNetActivityDidStop];
        [utils save];

        //  Trails are saved, so can now download conditions (asynchronously).
        if ( ! areaClient.error  &&  ! trailClient.error ) {
            [self downloadConditionsInArea:nil];
        }

        //  Delete unneeded managed objects.
        //
        if ( ! areaClient.error ) {
            //  We just downloaded all areas. Delete obsolete ones.
            deleteObjects( utils, @"areasDownloadedBefore", 0 );
            if ( trailClient.isUsed  &&  ! trailClient.error ) {
                //  We just downloaded all trails. Delete obsolete ones.
                deleteObjects( utils, @"trailsDownloadedBefore", 0 );
            }

            [utils save];
        }

        [trailClient release];
        [areaClient release];
        [utils release];
    } );
}


- (void) downloadConditions:(NSTimer*)timer {
    rescheduleTimerToNext( timer, ConditionInterval);
    [self downloadConditionsInArea:nil];    //  Get conditions in all areas.
}


- (void) downloadEvents:(NSTimer*)timer {
    rescheduleTimerToNext( timer, EventInterval );
    dispatch_async( getQ(), ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithProvisions:APP_DELEGATE
        ];
        utils.context.mergePolicy = NSOverwriteMergePolicy;

        EventWebClient* eventClient = [[EventWebClient alloc]
            initWithDataUtils:utils regionId:1
        ];

        [self aNetActivityDidStart];
        [eventClient sendSynchronousGet];
        [self aNetActivityDidStop];

        if ( ! eventClient.error ) {
            self.serverTimeEstimate = [eventClient serverTime];
            //  Delete all events whose endAt date has passed.
            [utils delete:@"expiredEvents"];
        }
        [utils save];

        [eventClient release];
        [utils release];
    } );
}


#pragma mark - Methods for triggering an ad hoc download


- (void) checkConditionsForArea:(Area*)area {
    NSDate* littleWhileAgo = [NSDate
        dateWithTimeIntervalSinceNow:-RecentEnoughInterval
    ];
    NSInteger count = [THE(dataUtils)
                      countOf:@"conditionsForAreaIdDownloadedBefore"
        substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                  [[NSNull null] unless:area.id],   @"id",
                                  littleWhileAgo,                   @"date",
                                  nil
                              ]
    ];
    //  If we haven't checked this area's conditions in a while, download them,
    //  but don't reset the timer.
    if ( count )  [self downloadConditionsInArea:area];
}


- (void) checkEvents {
    NSDate* littleWhileAgo = [NSDate
        dateWithTimeIntervalSinceNow:-RecentEnoughInterval
    ];
    NSInteger count = [THE(dataUtils)
                      countOf:@"eventsDownloadedBefore"
        substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                  littleWhileAgo,  @"date",
                                  nil
                              ]
    ];
    //  If we haven't checked in a while, download now and reset the timer.
    if ( count )  [self.eventDownloadTimer fire];
}


#pragma mark - Private methods and functions


/** Retrieve the dispatch queue used for the asynchronous actions in this file.
*/
dispatch_queue_t getQ() {
    return  dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0 );
}


/** Using the given CoreDataUtils object, deletes all managed objects obtained
    using the fetch request template of the given name with a $date argument
    which is the given interval earlier than the present.
*/
void deleteObjects(
    CoreDataUtils* utils, NSString* fetchName, NSTimeInterval age
) {
    NSDictionary* args = [NSDictionary
        dictionaryWithObject:[NSDate dateWithTimeIntervalSinceNow:-age]
                      forKey:@"date"
    ];
    [utils delete:fetchName substitutionVariables:args];
}


/** Resets the fire date on the given timer to the time anInterval from now.
    This is called when a timer fires in order to guarantee that AT LEAST
    anInterval will pass before the next firing.
*/
void rescheduleTimerToNext( NSTimer* timer, NSTimeInterval anInterval ) {
    return [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:anInterval]];
}


/** Sent to indicate that a network activity began. Tracks the number of such
    activities and displays the Network Activity Indicator if any activities
    have started and not ended yet. A call to this method must be followed
    at some point by a call to aNetActivityDidStop when the activity ends.
*/
- (void) aNetActivityDidStart {
    dispatch_async( dispatch_get_main_queue(), ^{
        __netActivitiesCount++;
        if ( __netActivitiesCount > 0 ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    } );
}


/** Sent to indicate that a network activity ended. Tracks the number of such
    activities and hides the Network Activity Indicator if all activities
    have ended. A call to this method must eventually follow the call to
    aNetActivityDidStart made when the activity began.
*/
- (void) aNetActivityDidStop {
    dispatch_async( dispatch_get_main_queue(), ^{
        __netActivitiesCount--;
        if ( __netActivitiesCount <= 0 ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } );
}


/** Asynchronously downloads all conditions in the given area of region 1, or
    in all areas of region 1 if given nil.
*/
- (void) downloadConditionsInArea:(Area*)area {
    dispatch_async( getQ(), ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithProvisions:APP_DELEGATE
        ];
        utils.context.mergePolicy = NSOverwriteMergePolicy;

        ConditionWebClient* condClient = area
        ?   [[ConditionWebClient alloc] initWithDataUtils:utils areaId:area.id]
        :   [[ConditionWebClient alloc] initWithDataUtils:utils regionId:1];

        [self aNetActivityDidStart];
        [condClient sendSynchronousGet];
        [self aNetActivityDidStop];

        if ( ! condClient.error ) {
            self.serverTimeEstimate = [condClient serverTime];

            //  Delete conditions that are too old. (Note that this happens
            //  whether or not we successfully downloaded new ones above.)
            deleteObjects(
                utils, @"conditionsUpdatedBefore", ConditionLifeSpan
            );
        }
        [utils save];

        [condClient release];
        [utils release];
    } );
}


@end
