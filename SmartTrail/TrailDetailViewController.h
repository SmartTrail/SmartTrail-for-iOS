//
//  TrailDetailViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trail.h"


@interface TrailDetailViewController : UIViewController


@property (retain,nonatomic) IBOutlet UIView*             statsView;
@property (retain,nonatomic) IBOutlet UILabel*            trailLengthLabel;
@property (retain,nonatomic) IBOutlet UILabel*            trailElevationGainLabel;
@property (retain,nonatomic) IBOutlet UISegmentedControl* segmentedControl;
@property (retain,nonatomic) IBOutlet UIView*             infoView;
@property (retain,nonatomic) IBOutlet UIView*             conditionView;
@property (retain,nonatomic) IBOutlet UIImageView*        techRatingImageView;
@property (retain,nonatomic) IBOutlet UIImageView*        aerobicRatingImageView;
@property (retain,nonatomic) IBOutlet UIImageView*        coolRatingImageView;
@property (retain,nonatomic) IBOutlet UIWebView*          descriptionWebView;
@property (retain,nonatomic)          Trail*              trail;

- (IBAction) segmentedControlChanged:(id)sender;

@end
