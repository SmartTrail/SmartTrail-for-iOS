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


@interface BMAController ()
- (void) aNetActivityDidStart;
- (void) aNetActivityDidStop;
@end


@implementation BMAController
{
    NSInteger netActivitiesCount;
}


- (void) downloadAllTrailInfo {

    dispatch_queue_t q = dispatch_get_global_queue(
        DISPATCH_QUEUE_PRIORITY_LOW, 0
    );
    dispatch_async( q, ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithProvisions:APP_DELEGATE
        ];
        [utils onSaveMergeChangesIntoContext:[APP_DELEGATE managedObjectContext]];

        AreaWebClient* areaClient = [[AreaWebClient  alloc]
            initWithDataUtils:utils regionId:1
        ];
        TrailWebClient* trailClient = [[TrailWebClient alloc]
            initWithDataUtils:utils regionId:1
        ];
        ConditionWebClient* condClient = [[ConditionWebClient alloc]
            initWithDataUtils:utils regionId:1
        ];

        [self aNetActivityDidStart];

        [areaClient sendSynchronousGet];
        if ( ! areaClient.error ) {

            NSDate* dateNow = areaClient.serverTime;
            NSAssert( dateNow, @"areaClient.serverTime is nil" );
            NSDictionary* now = [NSDictionary
                dictionaryWithObject:dateNow forKey:@"date"
            ];

            [utils delete:@"areasDownloadedBefore" substitutionVariables:now];

            [trailClient sendSynchronousGet];
            if ( ! trailClient.error ) {

                [utils
                                   delete:@"trailsDownloadedBefore"
                    substitutionVariables:now
                ];

                [condClient sendSynchronousGet];
                if ( ! condClient.error ) {
                    [utils
                                       delete:@"conditionsDownloadedBefore"
                        substitutionVariables:now
                    ];
                }
            }
        }

        [self aNetActivityDidStop];
        [utils save];

        [condClient release];
        [trailClient release];
        [areaClient release];
        [utils release];
    });
}


- (void) downloadEvents {
    dispatch_queue_t q = dispatch_get_global_queue(
        DISPATCH_QUEUE_PRIORITY_LOW, 0
    );
    dispatch_async( q, ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithProvisions:APP_DELEGATE
        ];
        [utils onSaveMergeChangesIntoContext:[APP_DELEGATE managedObjectContext]];

        EventWebClient* eventClient = [[EventWebClient alloc]
            initWithDataUtils:utils regionId:1
        ];
        [self aNetActivityDidStart];
        [eventClient sendSynchronousGet];
        [self aNetActivityDidStop];
        [utils save];

        [eventClient release];
        [utils release];
    });
}


#pragma mark - Private methods and functions


/** Sent to indicate that a network activity began. Tracks the number of such
    activities and displays the Network Activity Indicator if any activities
    have started and not ended yet. A call to this method must be followed
    at some point by a call to aNetActivityDidStop when the activity ends.
*/
- (void) aNetActivityDidStart {
    dispatch_async( dispatch_get_main_queue(), ^{
        netActivitiesCount++;
        if ( netActivitiesCount > 0 ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    });
}


/** Sent to indicate that a network activity ended. Tracks the number of such
    activities and hides the Network Activity Indicator if all activities
    have ended. A call to this method must eventually follow the call to
    aNetActivityDidStart made when the activity began.
*/
- (void) aNetActivityDidStop {
    dispatch_async( dispatch_get_main_queue(), ^{
        netActivitiesCount--;
        if ( netActivitiesCount <= 0 ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    });
}


@end
