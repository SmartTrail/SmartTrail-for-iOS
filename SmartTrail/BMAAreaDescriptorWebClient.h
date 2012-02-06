//
//  BMAAreaDescriptorWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMAAreaDescriptorWebClient;
@class BMAAreaDescriptor;

@protocol BMAAreaDescriptorWebClientEventNotifications <NSObject>

@optional

- (void) bmaAreaDescriptorWebClient : (BMAAreaDescriptorWebClient*) webClient didCompleteAreaRetrieval : (BOOL) successfully withAreaDescriptor : (BMAAreaDescriptor*) bmaAreaDescriptor;

@end

@interface BMAAreaDescriptorWebClient : NSObject
{
    NSURLConnection *urlConnection;
    NSMutableData *areaData;
}

@property(nonatomic, retain) id eventNotificationDelegate;

- (void) dealloc;
- (id) getAreaDescriptorForArea : (NSInteger) area;

@end
