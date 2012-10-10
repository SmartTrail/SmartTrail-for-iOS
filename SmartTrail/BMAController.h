//
//  BMAController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trail.h"

typedef void (^ActionWithURL)(NSURL*,BOOL);

/** Seconds between downloads of areas and trails. */
static const NSTimeInterval TrailInfoInterval = 86400.0;    // One day.

/** Seconds between downloads of conditions. */
static const NSTimeInterval ConditionInterval = 600.0;      // 10 min.

/** Seconds between downloads of events. */
static const NSTimeInterval EventInterval = 3600.0;         // One hour.

/** Seconds until next attempt if an area, trail, or event download failed. */
static const NSTimeInterval DownloadRetryInterval = 180.0;  // Three min.

/** A download is not done if the last one was done less than this many seconds
    ago. This applies only to downloads of conditions and events.
 */
static const NSTimeInterval RecentEnoughInterval = 180.0;   // Three min.

/** A Condition will be deleted if its updatedAt field is a date more than this
    many seconds in the past.
*/
static const NSTimeInterval ConditionLifeSpan = 2419200.0;  // Four weeks.

/** An Event will be deleted if its endedAt field is a date more than this many
    seconds in the past.
*/
static const NSTimeInterval ExpiredEventLifespan = 86400.0; // One day.

@class Area;


/** This class is the central clearinghouse for BMA data obtained via a
    RESTfull web API. It coordinates access to this model data with
    the persistent store (the app's version of model data) and with views and
    other controllers. Methods invoked on its single instance offer services
    to view controllers, often creating and persisting managed objects to hold
    the data. Thus, other classes usually don't receive the data directly, but
    are notified of changes to the saved data by way of
    NSFetchedResultsController objects, and automatically update their views
    accordingly. When instantiated, method init configures NSTimer objects
    to perform the data download and processing at regular intervals. The
    network activity indicator in the upper left corner of the screen is
    managed, informing the user when the app is downloading data.
*/
@interface BMAController : NSObject


/** Normally called by a view controller in response to some user action, this
    method downloads conditions of trails in the given Area. If the argument is
    nil, conditions are downloaded for ALL areas. Conditions older than
    ConditionLifeSpan are deleted.
*/
- (void) checkConditionsForArea:(Area*)area;


/** Normally called by a view controller in response to some user action,
    this method downloads all events. Expired Event managed objects are deleted,
    i.e., those whose whose endAt date has passed.
 */
- (void) checkEvents;


/** Provides an approximation of the current time according to the BMA server.
    It is corrected for accuracy each time conditions or events are downloaded.
    If the server has never provided the time since the app started, then nil
    is returned. Otherwise, an estimate based upon the most recently obtained
    server time is returned.
*/
- (NSDate*) serverTimeEstimate;


/** This method determines whether a KMZ file needs to be downloaded for the
    given trail. If so, it downloads and unzips the KMZ file whose URL is found
    in the given trail's kmzURL field, if non-nil.

    If the kmzURL field is nil, this method just returns.

    Otherwise, the directory designated by the trail's kmlDirPath field is
    checked. If it is non-nil, the directory exists, and its creation date is
    later than the trail's updatedAt field, then no download is performed.
    Nonetheless, the given block is called with the directory's URL and NO as
    arguments. Here, the second argument indicates that the data in the
    directory was not updated.

    Otherwise, new data must be downloaded and unzipped. After doing so, the
    given block is called with the directory's URL and YES as arguments. Here,
    the second argument indicates that the data in the directory is fresh.

    In all cases, if the block is called, its first (NSURL) argument will not be
    nil and the directory it designates is present.

    It could happen that no such directory can be obtained. In this case, the
    given block will simply not be invoked. This would happen, for example, if
    the given trail's kmzURL field is nil. Another likely example is when data
    should be downloaded, but the device is off line. It's also possible that
    the downloaded KMZ file could not be unzipped because it was somehow
    corrupted in transmission.

    If the async: argument is NO, then the download and the call of the block
    is performed synchronously in the current thread, so this method doesn't
    return until both are complete. If it is YES, then this method submits the
    download to a serial dispatch queue for this purpose, then returns. When
    the download completes, a block is submitted to the dispatch queue that was
    current when this method was called. It simply calls the given block with
    arguments as described above. This is handy when your block needs to do UI
    work: Just call this method from the main queue.

    The given trail is never modified, but you should probably update its
    kmlDirPath field (and maybe save its managed context) in the block using the
    provided path argument.
*/
- (void) checkKMZForTrail:(Trail*)trail thenDo:(ActionWithURL)blk async:(BOOL)a;


/** Runs method checkKMZForTrail:thenDo:async: for every trail, updates any
    Trail managed objects as needed, and saves the changes. Manages the
    network activity indicator. Runs synchronously, so returns only when
    finished.
*/
- (void) checkAllKMZs;

@end
