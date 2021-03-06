//
//  BMAController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAController.h"
#import "AppDelegate.h"
#import "NetActivityIndicatorController.h"
#import "AreaWebClient.h"
#import "TrailWebClient.h"
#import "ConditionWebClient.h"
#import "EventWebClient.h"
#import "Area.h"
#import "NSFileManager+Utils.h"
#import "NSDate+Utils.h"

@interface BMAController ()
- (void) downloadTrailsEtc:(NSTimer*)timer;
- (void) downloadConditions:(NSTimer*)timer;
- (void) downloadEvents:(NSTimer*)timer;
- (void)
  downloadKMZForTrail:(Trail*)t thenOnQ:(dispatch_queue_t)q do:(ActionWithURL)b;
static NSURL* unzipDataForID( NSData* zipData, NSString* idStr );
static void rescheduleTimerToNext( NSTimer* timer, NSTimeInterval anInterval );
static void deleteUsing( CoreDataUtils* u, NSString* f, NSDate* b );
- (NSDate*) ago:(NSTimeInterval)age;
- (void) downloadConditionsInArea:(Area*)area;
- (void) setServerTimeDeltaFromDate:(NSDate*)now;
@end

void maybeDispatch( dispatch_queue_t q, dispatch_block_t blk );


@implementation BMAController
{
    NSTimer* __eventDownloadTimer;
    NSNumber* __serverTimeDelta;
    dispatch_queue_t __areaTrailQ;
    dispatch_queue_t __conditionQ;
    dispatch_queue_t __kmzQ;
    dispatch_queue_t __eventQ;
}


- (void) dealloc {
    dispatch_release( __areaTrailQ );
    dispatch_release( __conditionQ );
    dispatch_release( __kmzQ );
    dispatch_release( __eventQ );
}


- (id) init {
    self = [super init];
    if ( self ) {

        __areaTrailQ = dispatch_queue_create(
            "BMAController_serial_areaTrailQ", DISPATCH_QUEUE_SERIAL
        );
        __conditionQ = dispatch_queue_create(
            "BMAController_serial_conditionQ", DISPATCH_QUEUE_SERIAL
        );
        __kmzQ = dispatch_queue_create(
            "BMAController_serial_kmzQ", DISPATCH_QUEUE_SERIAL
        );
        __eventQ = dispatch_queue_create(
            "BMAController_serial_eventQ", DISPATCH_QUEUE_SERIAL
        );

        [[NSTimer
            scheduledTimerWithTimeInterval:TrailInfoInterval
                                    target:self
                                  selector:@selector(downloadTrailsEtc:)
                                  userInfo:nil
                                   repeats:YES
        ] fire];

        [NSTimer
            scheduledTimerWithTimeInterval:ConditionInterval
                                    target:self
                                  selector:@selector(downloadConditions:)
                                  userInfo:nil
                                   repeats:YES
        ];
        //  No need to fire now, since conditions were downloaded w/ trail info.

        __eventDownloadTimer = [NSTimer
            scheduledTimerWithTimeInterval:EventInterval
                                    target:self
                                  selector:@selector(downloadEvents:)
                                  userInfo:nil
                                   repeats:YES
        ];
        [__eventDownloadTimer fire];
    }
    return  self;
}


#pragma mark - Methods for triggering an ad hoc download


- (void) checkConditionsForArea:(Area*)area {
    NSDate* littleWhileAgo = [self.serverTimeEstimate
        dateByAddingTimeInterval:-RecentEnoughInterval
    ];
    NSInteger count = 1;        // If we don't have time or area, download.

    if ( area && littleWhileAgo )  count = [THE(dataUtils)
                      countOf:@"conditionsForAreaIdDownloadedBefore"
        substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                  area.id,         @"id",
                                  littleWhileAgo,  @"date",
                                  nil
                              ]
    ];
    //  If we haven't checked this area's conditions in a while, download them,
    //  but don't reset the timer, since we may not have ALL conditions.
    if ( count )  [self downloadConditionsInArea:area];
}


- (void) checkEvents {
    NSDate* littleWhileAgo = [self.serverTimeEstimate
        dateByAddingTimeInterval:-RecentEnoughInterval
    ];
    NSInteger count = 1;        // In case we don't have server time, download.

    if ( littleWhileAgo )  count = [THE(dataUtils)
                      countOf:@"eventsDownloadedBefore"
        substitutionVariables:[NSDictionary dictionaryWithObjectsAndKeys:
                                  littleWhileAgo,  @"date",
                                  nil
                              ]
    ];
    //  If we haven't checked in a while, download now and reset the timer.
    if ( count )  [__eventDownloadTimer fire];
}


- (void)
    checkKMZForTrail:(Trail*)trail
             thenOnQ:(dispatch_queue_t)q
                  do:(ActionWithURL)block
{
    if ( trail.kmzURL ) {
        NSString* path = trail.kmlDirPath;

        if ( path ) {
            //  Have downloaded and unzipped a KMZ previously. Check when.
            NSDictionary* attrDict = [[NSFileManager defaultManager]
                attributesOfItemAtPath:path error:nil
            ];
            NSDate* downloadDate = [attrDict objectForKey:NSFileCreationDate];
            //  Note downloadDate is nil if path indicates a missing directory.

            if ( [downloadDate isAfter:trail.updatedAt] ) {
                //  The unzipped KMZ is current. Run the completion block
                //  and indicate that the directory does not have new data.
                if ( block ) {
                    block( [NSURL fileURLWithPath:path isDirectory:YES], NO );
                }

            } else {
                //  The unzipped KMZ is out of date or no longer exists. (It was
                //  stored in the cache directory, after all.) Replace it and
                //  run block.
NSLog(@"Re-downloading %@", trail.kmzURL);
                [self downloadKMZForTrail:trail thenOnQ:q do:block];
            }

        } else {
            //  There is a KMZ we haven't downloaded yet.
NSLog(@"Downloading new %@", trail.kmzURL);
            [self downloadKMZForTrail:trail thenOnQ:q do:block];
        }
    }
}


- (void) checkAllKMZsThenOnQ:(dispatch_queue_t)q do:(ActionWithTrails)block {
    maybeDispatch( (q ? __kmzQ : nil), ^(){
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithStoreCoordinator:[APP_DELEGATE persistentStoreCoordinator]
        ];
        utils.context.mergePolicy = NSOverwriteMergePolicy;

        //  Wrap the sequence of downloads in the display of the network
        //  activity spinner. Otherwise, it flashes as each KMZ is downloaded.
        [NetActivityIndicatorController aNetActivityDidStart];

        NSMutableArray* trailsWithMaps = [NSMutableArray new];
        for ( Trail* trail in [utils find:@"allTrails"] ) {
            [self checkKMZForTrail:trail
                           thenOnQ:nil
                                do:
                ^(NSURL* url, BOOL fresh) {
NSLog(@"Have%@ map %@", fresh ? @" new" : @"", [[url absoluteURL] path]);
                    [trailsWithMaps addObject:trail];
                    if ( fresh ) {
                        //  We have newly downloaded data, so we may need to
                        //  update the trail and persist it.
                        NSString* newPath = [[url absoluteURL] path];
                        if ( ! [newPath isEqual:trail.kmlDirPath] ) {
                            trail.kmlDirPath = newPath;
                        }
                    }
                }
            ];
        }

        [NetActivityIndicatorController aNetActivityDidStop];
        if ( block )  maybeDispatch( q, ^(){
            block(trailsWithMaps, utils);
        } );
    } );
}


#pragma mark - Server time


- (NSDate*) serverTimeEstimate {
    NSNumber* delta = __serverTimeDelta;
    return  delta
    ?   [NSDate dateWithTimeIntervalSinceNow:[delta doubleValue]]
    :   nil;
}


#pragma mark - Timer handlers (private)


/** Normally just called by the NSTimer objects configured in method init, this
    method requests data from the BMA server, parses the returned JSON, and
    creates or updates suitable Area, Trail, and Condition managed objects
    representing the data, and persists the objects. Although this method
    returns immediately while its work is performed asynchronously in a serial
    dispatch queue, the managed objects are populated in an order that ensures
    relationships between them are correct. In case this method was unable to be
    called at the scheduled time, this method resets the given timer to next
    fire in TrailInfoInterval seconds. This is so the start of these downloads
    will be be separated by at least that interval.
*/
- (void) downloadTrailsEtc:(NSTimer*)timer {
    rescheduleTimerToNext( timer, TrailInfoInterval );
    dispatch_async(__areaTrailQ, ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithStoreCoordinator:[APP_DELEGATE persistentStoreCoordinator]
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

        [NetActivityIndicatorController aNetActivityDidStart];

        //  Download all areas.
        [areaClient sendSynchronousGet];
        if ( areaClient.error ) {
            [NetActivityIndicatorController aNetActivityDidStop];
            [utils.context rollback];
            //  Try again next time, but don't wait so long.
            rescheduleTimerToNext( timer, DownloadRetryInterval);

        } else {
            //  Download all trails.
            [trailClient sendSynchronousGet];
            [NetActivityIndicatorController aNetActivityDidStop];

            //  We just downloaded all areas. Delete obsolete ones.
            deleteUsing(
                utils, @"areasDownloadedBefore", [areaClient serverTime]
            );
            [utils save];

            if ( trailClient.error ) {
                [utils.context rollback];
                //  Try again next time, but don't wait so long.
                rescheduleTimerToNext( timer, DownloadRetryInterval);

            } else {
                //  We just downloaded all trails. Delete obsolete ones.
                deleteUsing(
                    utils, @"trailsDownloadedBefore", [trailClient serverTime]
                );
                [utils save];

                //  Trails are saved, now asynchronously download all conditions
                //  for all trails.
                [self downloadConditionsInArea:nil];

                //  Check each trail and download its KMZ file if necessary.
//todo                [self checkAllKMZsAsync:YES thenDo:nil];
            }
        }
    } );
}


/** Normally just called by the NSTimer objects configured in method init,
    this method downloads, processes, and persists Condition data into managed
    objects. It returns immediately while its work is performed in the
    background. In case this method was unable to be called at the scheduled
    time, this method resets the given timer to next fire in ConditionInterval
    seconds. This is so the start of these downloads will be be separated by at
    least that interval.  Conditions older than ConditionLifeSpan are deleted.
*/
- (void) downloadConditions:(NSTimer*)timer {
    rescheduleTimerToNext( timer, ConditionInterval);
    [self downloadConditionsInArea:nil];    //  Get conditions in all areas.
}


/** Normally just called by the NSTimer objects configured in method init, this
    method downloads, processes, and persists Event data into managed objects.
    It returns immediately while its work is performed in the background. In
    case this method was unable to be called at the scheduled time, this method
    resets the given timer to next fire in EventInterval seconds. This is so the
    start of these downloads will be be separated by at least that interval.
    Expired Event managed objects are deleted, i.e., those whose whose endAt
    date has passed.

    See comments below for method downloadConditionsInArea: explaining why this
    method does its work in a serial queue. In a nutshell, it's because method
    checkEvents: (like checkConditionsForArea:) can create a new context at any
    time, possibly resulting in duplicates.
*/
- (void) downloadEvents:(NSTimer*)timer {
    rescheduleTimerToNext( timer, EventInterval );
    dispatch_async( __eventQ, ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithStoreCoordinator:[APP_DELEGATE persistentStoreCoordinator]
        ];
        utils.context.mergePolicy = NSOverwriteMergePolicy;

        EventWebClient* eventClient = [[EventWebClient alloc]
            initWithDataUtils:utils regionId:1
        ];

        [NetActivityIndicatorController aNetActivityDidStart];
        [eventClient sendSynchronousGet];
        [NetActivityIndicatorController aNetActivityDidStop];

        if ( eventClient.error ) {
            [utils.context rollback];
            //  Try again next time, but don't wait so long.
            rescheduleTimerToNext( timer, DownloadRetryInterval);

        } else {
            [self setServerTimeDeltaFromDate:[eventClient serverTime]];
            //  Delete all events that expired at least ExpiredEventLifespan ago.
            NSDate* whileAgo = [[eventClient serverTime]
                dateByAddingTimeInterval:-ExpiredEventLifespan
            ];
            deleteUsing(
                utils, @"eventsEndedBefore", whileAgo
            );
            [utils save];
        }
    } );
}


#pragma mark - Other private methods and functions


/** Performs the downloading and unzipping of a KMZ file required by method
    checkKMZForTrail:thenOnQ:do:. If given a non-nil dispatch queue, this method
    returns immediately, doing its work in the background on the __kmzQ serial
    queue, then the given block is executed on the given queue. If the given
    queue is nil, then this is all performed synchronously. The given Trail
    is not modified.
*/
- (void)
    downloadKMZForTrail:(Trail*)trail
                thenOnQ:(dispatch_queue_t)q
                     do:(ActionWithURL)block
{
    NSString* trailId = trail.id;
    WebClient* client = [WebClient new];

    client.urlString = trail.kmzURL;
    client.baseURLString = [[NSBundle mainBundle]   // kmzURL is relative.
        objectForInfoDictionaryKey:@"BmaBaseUrl"
    ];
    client.processData = ^( NSData* zipData ){
        NSURL* kmlDirURL = unzipDataForID( zipData, trailId );
        if ( kmlDirURL && block ) {
            //  Succeeded in unzipping the downloaded data and moving the
            //  resulting dir. into the cache directory. Now call the given
            //  block in the original dispatch queue and indicate that the
            //  downloaded data is fresh.
            maybeDispatch( q, ^{ block(kmlDirURL, YES); } );
        }
    };

    maybeDispatch( q ? __kmzQ : nil,  ^{
        [NetActivityIndicatorController aNetActivityDidStart];
        [client sendSynchronousGet];
        [NetActivityIndicatorController aNetActivityDidStop];
    } );
}


/** Unzips the given zip-compressed data and stores it in a new directory whose
    name is based on the given ID string. For example, if idStr is "42", the
    directory will have name "42.kmz.d" located in the app's cache directory.
    The file URL for the directory is returned, or nil if there was an error.
    If either argument is nil or empty, this function just returns nil.
*/
NSURL* unzipDataForID( NSData* zipData, NSString* idStr ) {
    NSURL* kmlDirURL = nil;

    if ( [zipData length] && [idStr length] ) {
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        //  (NSFileManager is thread-safe, since we're not using a delegate.)

        NSString* kmlDirName = [idStr stringByAppendingString:@".kmz.d"];
        NSURL* kmlDirTmpURL = [fileMgr tmpURLEndingInPathComponent:kmlDirName];
        NSURL* kmzTmpURL = [fileMgr
            tmpURLEndingInPathComponent:[idStr stringByAppendingString:@".kmz"]
        ];

        if ( ! [zipData writeToURL:kmzTmpURL atomically:YES] ) {
            NSCAssert( NO, @"Couldn't write zip data to URL %@", kmzTmpURL );

        } else if ( ! [fileMgr unzip:kmzTmpURL intoNewDirAtURL:kmlDirTmpURL] ) {
            NSCAssert( NO, @"Couldn't unzip data %@ into directory %@", kmzTmpURL, kmlDirTmpURL );

        } else if (
            ! ( kmlDirURL = [fileMgr cacheURLEndingInPathComponent:kmlDirName] )
        ) {
            NSCAssert( NO, @"Couldn't create cache URL for %@", kmlDirName );

        } else if (
            [fileMgr removeItemAtURL:kmlDirURL error:nil],  // <-- OK to fail.
            ! [fileMgr moveItemAtURL:kmlDirTmpURL toURL:kmlDirURL error:nil]
        ) {
            NSCAssert( NO, @"Couldn't move directory %@ to %@", kmlDirTmpURL, kmlDirURL );
        }
    }
    return  kmlDirURL;
}


/** Resets the fire date on the given timer to the time anInterval from now.
    This is called when a timer fires in order to guarantee that AT LEAST
    anInterval will pass before the next firing.
*/
void rescheduleTimerToNext( NSTimer* timer, NSTimeInterval anInterval ) {
    return [timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:anInterval]];
}


/** Deletes the managed objects in utils.context returned by the fetch request
    whose template has the given name and which accepts a single date parameter.
    If the date argument is nil, this method does nothing. This is handy if
    we're passing a WebClient's serverTime result, and it is unavailable.
*/
void deleteUsing(
    CoreDataUtils* utils, NSString* fetchName, NSDate* beforeThis
) {
    if ( beforeThis ) {
        NSDictionary* args = [NSDictionary
            dictionaryWithObject:beforeThis
                          forKey:@"date"
        ];
        [utils delete:fetchName substitutionVariables:args];
    }
}


/** Calculates the current time minus the given interval. The current time is
    obtained from method serverTimeEstimate, which could be nil. In this case,
    nil is returned.
*/
- (NSDate*) ago:(NSTimeInterval)age {
    return  [[self serverTimeEstimate] dateByAddingTimeInterval:-age];
}


/** This method downloads all conditions in the given area of region 1, or in
    all areas of region 1 if given nil. Although it is asynchronous, returning
    immediately, all calls do the work on the same serial queue. This is because
    it is possible that this method is called before another call finishes. For
    example, the user activates the app for the first time in TrailInfoInterval,
    causing conditions to be downloaded after the areas and trails. If, before
    utils.context is saved, the user tapped a particular trail in the GUI, this
    method would again run its block again and cause identical conditions to be
    loaded into a second utils.context, because this utils is necessarily
    distinct from the previous one. Then CoreDataUtils'
    updateOrInsertThe:withProperties:matchingKey: method would not know about
    Condition managed objects that were loaded into the previous utils.context
    but not yet saved. Thus, duplicate conditions are likely to be created.
*/
- (void) downloadConditionsInArea:(Area*)area {
    dispatch_async( __conditionQ, ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithStoreCoordinator:[APP_DELEGATE persistentStoreCoordinator]
        ];
        utils.context.mergePolicy = NSOverwriteMergePolicy;

        ConditionWebClient* condClient = area
        ?   [[ConditionWebClient alloc] initWithDataUtils:utils areaId:area.id]
        :   [[ConditionWebClient alloc] initWithDataUtils:utils regionId:1];

        [NetActivityIndicatorController aNetActivityDidStart];
        [condClient sendSynchronousGet];
        [NetActivityIndicatorController aNetActivityDidStop];

        if ( ! condClient.error ) {
            [self setServerTimeDeltaFromDate:[condClient serverTime]];

            //  Delete conditions that are too old. (Note that this happens
            //  whether or not we successfully downloaded new ones above.)
            deleteUsing(
                utils, @"conditionsUpdatedBefore", [self ago:ConditionLifeSpan]
            );
        }
        [utils save];
    } );
}


/** Record the difference between the system time and the server time in the
    serverTimeDelta property. If the argument is nil, a warning is logged in
    debug mode and no change is made to serverTimeDelta. The property is an
    NSNumber object, so will remain nil if we've never obtained the server time.
*/
- (void) setServerTimeDeltaFromDate:(NSDate*)now {
    if ( now ) {
        __serverTimeDelta = [NSNumber numberWithDouble:
            [now timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970]
        ];
    } else {
#ifdef DEBUG
        NSLog( @"Warning: WebClient's setServerTimeDeltaFromDate: method did not receive the current time from the server." );
#endif
    }
}


/** A function that can substitute for functions like dispatch_async to NOT
    do such a dispatch, but to just run the given block now. Returns when the
    given block returns.
*/
void maybeDispatch( dispatch_queue_t q, dispatch_block_t blk ) {
    if ( q )  dispatch_async(q, blk);
    else  blk();
}


@end
