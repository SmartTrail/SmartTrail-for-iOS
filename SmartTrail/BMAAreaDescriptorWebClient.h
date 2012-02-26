//
//  BMAAreaDescriptorWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Area.h"

@class BMAAreaDescriptorWebClient;

@protocol BMAAreaDescriptorWebClientEventNotifications <NSObject>

@optional

- (void)
    bmaAreaDescriptorWebClient:(BMAAreaDescriptorWebClient*)webClient
      didCompleteAreaRetrieval:(BOOL)successfully
                      withArea:(Area*)area;

@end

@interface BMAAreaDescriptorWebClient : NSObject
{
    NSURLConnection *urlConnection;
    NSMutableData *areaData;
}

@property(nonatomic, retain) id eventNotificationDelegate;

- (id) getAreaDescriptorForArea : (NSInteger) area;

@end
