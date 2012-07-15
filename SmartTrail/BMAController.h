//
//  BMAController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Trail.h"

typedef void (^ActionWithURL)(NSURL*);

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
    in the given trail's kmzURL field, if non-nil. After download of the KMZ
    file, it then queues-up the given block in the main dispatch queue. The
    given block will be called with an NSURL argument representing the new
    directory containing the uncompressed KML file and any resources
    accompanying it. If no download was done, e.g., when the device is off line,
    or if the downloaded data could not be unzipped to a file, then the given
    block is not called.

    The given trail is never modified, but you should probably update its
    kmlDirPath field (and maybe save its managed context) in the block using the
    provided path argument.
*/
- (void) checkKMZForTrail:(Trail*)trail thenDo:(ActionWithURL)block;


@end
