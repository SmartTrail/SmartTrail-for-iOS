//
//  BMAEventsDescriptorWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMAEventsDescriptorWebClient;

@protocol BMAEventsDescriptorEventNotifications <NSObject>

- (void) bmaEventsDescriptionWebClient : (BMAEventsDescriptorWebClient*) webClient didCompleteEventRetrieval : (BOOL) successfully withResultArray : (NSArray*) resultArray;

@end

@interface BMAEventsDescriptorWebClient : NSObject
{
    NSURLConnection *urlConnection;
    NSMutableData *eventData;
}

@property (nonatomic, retain) id<BMAEventsDescriptorEventNotifications> eventNotificationDelegate;

- (void) dealloc;
- (id) getEventsForRegion : (NSUInteger) region;

@end
