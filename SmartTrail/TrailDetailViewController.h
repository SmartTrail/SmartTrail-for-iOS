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

@property (retain,nonatomic) IBOutlet UILabel* trailNameLabel;
@property (retain,nonatomic)          Trail*   trail;

@end
