//
//  EventDetailViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event+Display.h"

@interface EventDetailViewController : UIViewController

@property (retain,nonatomic) IBOutlet UILabel*   titleLabel;
@property (retain,nonatomic) IBOutlet UILabel*   dateRangeLabel;
@property (retain,nonatomic) IBOutlet UIWebView* descriptionWebView;
@property (retain,nonatomic)          Event*     event;

@end
