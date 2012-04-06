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


@implementation BMAController


- (void) downloadAllTrailInfo {

    dispatch_queue_t q = dispatch_get_global_queue(
        DISPATCH_QUEUE_PRIORITY_HIGH, 0
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

        [utils save];

        [utils release];
        [condClient release];
        [trailClient release];
        [areaClient release];
    });
}


- (void) downloadEvents {
    dispatch_queue_t q = dispatch_get_global_queue(
        DISPATCH_QUEUE_PRIORITY_HIGH, 0
    );
    dispatch_async( q, ^{
        CoreDataUtils* utils = [[CoreDataUtils alloc]
            initWithProvisions:APP_DELEGATE
        ];
        [utils onSaveMergeChangesIntoContext:[APP_DELEGATE managedObjectContext]];

        EventWebClient* eventClient = [[EventWebClient alloc]
            initWithDataUtils:utils regionId:1
        ];
        [eventClient sendSynchronousGet];
        [utils save];

        [eventClient release];
        [utils release];
    });
}


@end
