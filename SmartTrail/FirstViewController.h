//
//  FirstViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2011-12-10.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMAWebClient.h"
#import "BMAAreaDescriptorsWebClient.h"
#import "BMAAreaDescriptorWebClient.h"
#import "BMATrailsDescriptorWebClient.h"
#import "BMATrailDescriptorWebClient.h"
#import "BMAConditionsDescriptorWebClient.h"

@interface FirstViewController : UIViewController
<
    BMAWebClientNotifications,
    BMAAreaDescriptorsWebClientEventNotifications,
    BMATrailsDescriptorWebClientEventNotifications,
    BMATrailDescriptorWebClientEventNotifications,
    BMAConditionsDescriptorWebClient
>

@end
