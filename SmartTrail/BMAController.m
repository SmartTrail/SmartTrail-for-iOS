//
//  BMAController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAController.h"
#import "BMAConditionDescriptor.h"
#import "BMAEventDescriptor.h"
#import "AppDelegate.h"


@implementation BMAController


- (void) downloadAreasAndTrails {

    //  Note that BMATrailsDescriptorWebClient establishes the relationship
    //  between each Trail and its Area. However, as currently written,
    //  BMAAreaDescriptorsWebClient does not hook up to Trails. When a Trail's
    //  "area" relationship is assigned its Area managed object, Core Data
    //  automatically adds the Trail to the Area's "trail" relationship. Thus,
    //  the getAreaDescriptorsForRegion: call must precede the call to
    //  getTrailsDescriptorForRegion:, as below. That way, the Area objects
    //  exist for getTrailsDescriptorForRegion: to find.

    BMAAreaDescriptorsWebClient *areaDescriptorsWebClient =
        [[[BMAAreaDescriptorsWebClient alloc] init] autorelease];
    [areaDescriptorsWebClient setEventNotificationDelegate:self];
    [areaDescriptorsWebClient getAreaDescriptorsForRegion:1];

    BMATrailsDescriptorWebClient *trailsDescriptorWebClient =
        [[[BMATrailsDescriptorWebClient alloc] init] autorelease];
    [trailsDescriptorWebClient setEventNotificationDelegate:self];
    [trailsDescriptorWebClient getTrailsDescriptorForRegion:1];

    [APP_DELEGATE saveContext];
}


#pragma mark - Protocol methods


- (void) bmaWebClient : (BMAWebClient*) webClient didCompleteLogin : (BOOL) successfully
{
    NSLog(@"Got %@ login completion event.", successfully ? @"successful" : @"unsuccessful");
    [webClient logOutOfBmaWebSiteAsync];
}


- (void)
    bmaAreaDescriptorsWebClient:(BMAAreaDescriptorsWebClient*)webClient
       didCompleteAreaRetrieval:(BOOL)successfully;
{
    NSLog( @"Multiple area retrieval %@.", successfully ? @"succeeded" : @"failed" );
    [webClient setEventNotificationDelegate:nil];
}


- (void)
    bmaAreaDescriptorWebClient:(BMAAreaDescriptorWebClient*)webClient
      didCompleteAreaRetrieval:(BOOL)successfully
                      withArea:(Area*)area
{
    NSLog( @"Area retrieval %@.", successfully ? @"succeeded" : @"failed" );
    [webClient setEventNotificationDelegate:nil];
}


- (void)
    bmaTrailDescriptorsWebClient:(BMATrailsDescriptorWebClient*)webClient
       didCompleteTrailRetrieval:(BOOL)successfully
{
    NSLog( @"Multiple trail retrieval %@.", successfully ? @"succeeded" : @"failed" );
    [webClient setEventNotificationDelegate:nil];
}


- (void)
    bmaTrailDescriptorWebClient:(BMATrailDescriptorWebClient*)webClient
      didCompleteTrailRetrieval:(BOOL)successfully
                      withTrail:(Trail*)trail
{
    NSLog( @"Trail retrieval %@.", successfully ? @"succeeded" : @"failed" );
    [webClient setEventNotificationDelegate: nil];
}


- (void) bmaTrailConditionsWebClient : (BMAConditionsDescriptorWebClient*) webClient didCompleteConditionRetrieval : (BOOL) successfully withResultArray : (NSArray*) resultArray
{
    for(BMAConditionDescriptor *conditionDescriptor in resultArray)
    {
        NSLog(@"%@", conditionDescriptor);
    }

    [webClient setEventNotificationDelegate:nil];
}


- (void) bmaEventsDescriptionWebClient : (BMAEventsDescriptorWebClient*) webClient didCompleteEventRetrieval : (BOOL) successfully withResultArray : (NSArray*) resultArray
{
    for(BMAEventDescriptor *eventDescriptor in resultArray)
    {
        NSLog(@"%@", eventDescriptor);
    }

    [webClient setEventNotificationDelegate:nil];
}


@end
