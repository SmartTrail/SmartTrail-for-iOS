//
//  TrailDetailViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trail.h"
#import "TrailInfoController.h"
#import "TrailConditionsController.h"


/** Responsible for display and interaction with a single trail.
*/
@interface TrailDetailViewController : UIViewController


@property (nonatomic)        IBOutlet UISegmentedControl*
                                                    segmentedControl;

@property (strong,nonatomic) IBOutlet TrailInfoController*
                                                    trailInfoController;

@property (strong,nonatomic) IBOutlet TrailConditionsController*
                                                    trailConditionsController;

@property (strong,nonatomic)          Trail*        trail;

- (IBAction) segmentedControlChanged:(id)sender;


@end
