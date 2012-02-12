//
//  BMAAreaDescriptorWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMAAreaDescriptorsWebClient;

@protocol BMAAreaDescriptorsWebClientEventNotifications <NSObject>

@optional

- (void) bmaAreaDescriptorsWebClient : (BMAAreaDescriptorsWebClient*) webClient didCompleteAreaRetrieval : (BOOL) successfully withResultArray : (NSArray*) resultArray;

@end

@interface BMAAreaDescriptorsWebClient : NSObject
{
    NSURLConnection *urlConnection;
    NSMutableData *areaData;
}

@property(nonatomic, retain) id<BMAAreaDescriptorsWebClientEventNotifications> eventNotificationDelegate;

- (void) dealloc;
- (id) getAreaDescriptorsForRegion : (NSInteger) region;

@end
