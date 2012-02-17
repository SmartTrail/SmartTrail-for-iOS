//
//  BMAController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAController.h"
#import "BMAAreaDescriptor.h"
#import "BMATrailDescriptor.h"
#import "BMAConditionDescriptor.h"
#import "BMAEventDescriptor.h"


@implementation BMAController


- (void) downloadAreasAndTrails {

    //  Note that BMATrailsDescriptorWebClient establishes the relationship
    //  between each Trail and its Area. However, as currently written,
    //  BMAAreaDescriptorsWebClient does not hook up to Trails. When a Trail's
    //  "area" relationship is assigned its Area managed object, Core Data
    //  automatically adds the Trail to the Area's "trail" relationship. Thus,
    //  the getAreaDescriptorsForRegion: call must preceed the
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
}


#pragma mark - Protocol methods


- (void) bmaWebClient : (BMAWebClient*) webClient didCompleteLogin : (BOOL) successfully
{
    NSLog(@"Got %@ login completion event.", successfully ? @"successful" : @"unsuccessful");
    [webClient logOutOfBmaWebSiteAsync];
}


- (void) bmaAreaDescriptorsWebClient : (BMAAreaDescriptorsWebClient*) webClient didCompleteAreaRetrieval : (BOOL) successfully withResultArray : (NSArray*) resultArray;
{
    for(BMAAreaDescriptor *bmaAreaDescriptor in resultArray)
    {
        NSLog(@"%@", [bmaAreaDescriptor areaName]);
    }
    
    [webClient setEventNotificationDelegate:nil];
}


- (void) bmaAreaDescriptorWebClient : (BMAAreaDescriptorWebClient*) webClient didCompleteAreaRetrieval : (BOOL) successfully withAreaDescriptor : (BMAAreaDescriptor*) areaDescriptor
{
    NSLog(@"%@", [areaDescriptor areaName]);
    [webClient setEventNotificationDelegate:nil];
}


- (void) bmaTrailDescriptorsWebClient : (BMATrailsDescriptorWebClient*) webClient didCompleteTrailRetrieval : (BOOL) successfully withResultArray : (NSArray*) resultArray
{
    for(BMATrailDescriptor *trailDescriptor in resultArray)
    {
        NSLog(@"%@", trailDescriptor);
    }
    
    [webClient setEventNotificationDelegate:nil];
}


- (void) bmaTrailDescriptorWebClient : (BMATrailDescriptorWebClient*) webClient didCompleteTrailRetrieval : (BOOL) successfully withTrailDescriptor : (BMATrailDescriptor*) trailDescriptor
{
    NSLog(@"%@", trailDescriptor);
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
