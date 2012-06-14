//
//  EventDetailViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event+Display.h"
#import "LinkingWebViewDelegate.h"

@interface EventDetailViewController : UIViewController

@property (nonatomic) IBOutlet UILabel*      titleLabel;
@property (nonatomic) IBOutlet UILabel*      dateRangeLabel;
@property (nonatomic) IBOutlet UIWebView*    descriptionWebView;
@property (nonatomic) IBOutlet LinkingWebViewDelegate*
                                                    linkingWebViewDelegate;
@property (nonatomic)          Event*        event;

@end
