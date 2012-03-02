//
//  BMAConditionsDescriptorWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMAConditionsDescriptorWebClient;

@protocol BMAConditionsDescriptorWebClientEventNotifications <NSObject>

@optional

- (void)
      bmaTrailConditionsWebClient:(BMAConditionsDescriptorWebClient*)webClient
    didCompleteConditionRetrieval:(BOOL)successfully;

@end

@interface BMAConditionsDescriptorWebClient : NSObject
{
    NSURLConnection *urlConnection;
    NSMutableData *conditionData;
}

@property (nonatomic, retain) id<BMAConditionsDescriptorWebClientEventNotifications> eventNotificationDelegate;

- (void) dealloc;
- (id) getTrailConditionsForRegion : (NSInteger) region;
- (id) getTrailConditionsForArea : (NSInteger) area;
- (id) getTrailConditionsForTrail : (NSInteger) trail;

@end
