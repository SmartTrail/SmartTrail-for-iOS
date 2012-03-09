//
//  BMAController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMAWebClient.h"
#import "BMAAreaDescriptorsWebClient.h"
#import "BMAAreaDescriptorWebClient.h"
#import "BMATrailsDescriptorWebClient.h"
#import "BMATrailDescriptorWebClient.h"
#import "BMAConditionsDescriptorWebClient.h"
#import "BMAEventsDescriptorWebClient.h"

@interface BMAController : NSObject
<
    BMAWebClientNotifications,
    BMAAreaDescriptorsWebClientEventNotifications,
    BMATrailsDescriptorWebClientEventNotifications,
    BMATrailDescriptorWebClientEventNotifications,
    BMAConditionsDescriptorWebClientEventNotifications,
    BMAEventsDescriptorEventNotifications
>

- (void) downloadAllTrailInfo;

@end
