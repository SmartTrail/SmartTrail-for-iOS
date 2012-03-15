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
#import "Condition.h"


@implementation BMAController


- (void) downloadAllTrailInfo {

    //  Note that BMATrailsDescriptorWebClient establishes the relationship
    //  between each Trail and its Area. However, as currently written,
    //  BMAAreaDescriptorsWebClient does not hook up to Trails. When a Trail's
    //  "area" relationship is assigned an Area managed object, Core Data
    //  automatically adds the Trail to the Area's "trails" relationship. Thus,
    //  the getAreaDescriptorsForRegion: call must precede the call to
    //  getTrailsDescriptorForRegion:, as below. That way, the Area objects
    //  exist for getTrailsDescriptorForRegion: to find.
    //
    //  Similarly, BMAConditionsDescriptorWebClient wires up Condition's "trail"
    //  relationship (and thus also Trail's "conditions" relationship), so the
    //  getTrailConditionsForRegion: call must be preceded by the call to
    //  getTrailsDescriptorForRegion:.
    //
    //  TODO: Unfortunately, since the get... methods below are asynchronous,
    //  there is no guarantee that they will finish in this order. I think they
    //  should instead run synchronously and be kicked off by a job queue in a
    //  separate thread. As it is, this works well enough to work on
    //  implementing the GUI, but it needs to be fixed.
    //
    //  I see this method being called only occasionally, since Trail and Area
    //  info will rarely go out of date. Conditions change frequently, however,
    //  so should be downloaded often. A good policy would be to look at the
    //  maximum downloadedAt value of the conditions of a tapped trail. If
    //  there are no conditions, or if the latest of these values is not within,
    //  say, an hour of the present, the conditions for the entire area of the
    //  trail should be downloaded. Loading conditions for the whole area won't
    //  take much longer than loading just the conditions for the single trail,
    //  and it anticipates that maybe the user is perusing multiple trails
    //  in the area.

    BMAAreaDescriptorsWebClient *areaDescriptorsWebClient =
        [[BMAAreaDescriptorsWebClient new] autorelease];
    [areaDescriptorsWebClient setEventNotificationDelegate:self];
    [areaDescriptorsWebClient getAreaDescriptorsForRegion:1];

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

    BMATrailsDescriptorWebClient *trailsDescriptorWebClient =
        [[BMATrailsDescriptorWebClient new] autorelease];
    [trailsDescriptorWebClient setEventNotificationDelegate:self];
    [trailsDescriptorWebClient getTrailsDescriptorForRegion:1];
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

    BMAConditionsDescriptorWebClient* conditionDescriptorsWebClient =
        [[BMAConditionsDescriptorWebClient new] autorelease];
    [conditionDescriptorsWebClient setEventNotificationDelegate:self];
    [conditionDescriptorsWebClient getTrailConditionsForRegion:1];
}


- (void)
    bmaTrailDescriptorWebClient:(BMATrailDescriptorWebClient*)webClient
      didCompleteTrailRetrieval:(BOOL)successfully
                      withTrail:(Trail*)trail
{
    NSLog( @"Trail retrieval %@.", successfully ? @"succeeded" : @"failed" );
    [webClient setEventNotificationDelegate: nil];
}


- (void)
      bmaTrailConditionsWebClient:(BMAConditionsDescriptorWebClient*)webClient
    didCompleteConditionRetrieval:(BOOL)successfully
{
    NSLog( @"Multiple condition retrieval %@.", successfully ? @"succeeded" : @"failed" );
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
