//
//  TrailDetailViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trail.h"


/** This class is a container view controller responsible for the display of and
    interaction with a single trail. Its child view controllers can be laid out
    in Interface Builder, and must have identifiers "TrailInfo",
    "TrailConditions", and "TrailMap" corresponding to the respective buttons
    in the UISegmentedControl.
*/
@interface TrailDetailViewController : UIViewController


@property (nonatomic)        IBOutlet UISegmentedControl*
                                                    segmentedControl;
@property (nonatomic)        IBOutlet UIView*       contentView;


/** The trail being examined.
*/
@property (strong,nonatomic)          Trail*        trail;


- (IBAction) segmentedControlChanged:(id)sender;


@end
