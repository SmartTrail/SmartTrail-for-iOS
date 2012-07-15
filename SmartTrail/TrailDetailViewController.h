//
//  TrailDetailViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trail.h"
#import "TrailConditionsController.h"
#import "LinkingWebViewDelegate.h"


@interface TrailDetailViewController : UIViewController

@property (nonatomic) IBOutlet UILabel*            statsLabel;
@property (nonatomic) IBOutlet UISegmentedControl* segmentedControl;
@property (nonatomic) IBOutlet UIView*             infoView;
@property (nonatomic) IBOutlet UIImageView*        techRatingImageView;
@property (nonatomic) IBOutlet UIImageView*        aerobicRatingImageView;
@property (nonatomic) IBOutlet UIImageView*        coolRatingImageView;
@property (nonatomic) IBOutlet UIWebView*          descriptionWebView;
@property (strong,nonatomic) IBOutlet LinkingWebViewDelegate*
                                                   linkingWebViewDelegate;
@property (strong,nonatomic) IBOutlet TrailConditionsController*
                                                   trailConditionsController;
@property (strong,nonatomic)   Trail*              trail;

- (IBAction) segmentedControlChanged:(id)sender;

@end
