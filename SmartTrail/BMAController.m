//
//  BMAController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAController.h"
#import "BMAEventDescriptor.h"
#import "AppDelegate.h"
#import "AreaWebClient.h"
#import "TrailWebClient.h"
#import "ConditionWebClient.h"


@implementation BMAController


- (void) downloadAllTrailInfo {
    //  TODO  Wrap this sequence in a new thread.
    [[[[AreaWebClient  alloc] initWithRegionId:1] autorelease] sendSynchronousGet];
    [[[[TrailWebClient alloc] initWithRegionId:1] autorelease] sendSynchronousGet];
    [[[ConditionWebClient new] autorelease] sendSynchronousGet];
    [APP_DELEGATE saveContext];
}


@end
