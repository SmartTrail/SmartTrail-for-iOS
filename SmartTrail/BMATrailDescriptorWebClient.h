//
//  BMATrailDescriptorWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMATrailDescriptorWebClient;
@class BMATrailDescriptor;

@protocol BMATrailDescriptorWebClientEventNotifications <NSObject>

@optional

- (void) bmaTrailDescriptorWebClient : (BMATrailDescriptorWebClient*) webClient didCompleteTrailRetrieval : (BOOL) successfully withTrailDescriptor : (BMATrailDescriptor*) trailDescriptor;

@end

@interface BMATrailDescriptorWebClient : NSObject
{
    NSURLConnection *urlConnection;
    NSMutableData *trailData;
}

@property (nonatomic, retain) id<BMATrailDescriptorWebClientEventNotifications> eventNotificationDelegate;

- (void) dealloc;
- (id) getTrailDescriptorForTrail : (NSInteger) trail;

@end
