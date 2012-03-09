//
//  BMATrailsDescriptorWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMATrailsDescriptorWebClient;

@protocol BMATrailsDescriptorWebClientEventNotifications <NSObject>

@optional

- (void)
    bmaTrailDescriptorsWebClient:(BMATrailsDescriptorWebClient*)webClient
       didCompleteTrailRetrieval:(BOOL)successfully;

@end

@interface BMATrailsDescriptorWebClient : NSObject

@property (nonatomic, retain) id<BMATrailsDescriptorWebClientEventNotifications> eventNotificationDelegate;

- (void) dealloc;
- (id) getTrailsDescriptorForArea : (NSInteger) area;
- (id) getTrailsDescriptorForRegion : (NSInteger) region;

@end
