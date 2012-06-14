//
//  TrailDetailViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Trail.h"
#import "FetchedResultsTableDataSource.h"
#import "LinkingWebViewDelegate.h"


@interface TrailDetailViewController :
    UIViewController<UITableViewDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic) IBOutlet UILabel*            statsLabel;
@property (nonatomic) IBOutlet UISegmentedControl* segmentedControl;
@property (nonatomic) IBOutlet UIView*             infoView;
@property (nonatomic) IBOutlet UITableView*        conditionView;
@property (nonatomic) IBOutlet UIImageView*        techRatingImageView;
@property (nonatomic) IBOutlet UIImageView*        aerobicRatingImageView;
@property (nonatomic) IBOutlet UIImageView*        coolRatingImageView;
@property (nonatomic) IBOutlet UIWebView*          descriptionWebView;
@property (nonatomic) IBOutlet FetchedResultsTableDataSource*
                                                   conditionsDataSource;
@property (nonatomic) IBOutlet LinkingWebViewDelegate*
                                                   linkingWebViewDelegate;
@property (nonatomic)          Trail*              trail;

- (IBAction) segmentedControlChanged:(id)sender;

@end
