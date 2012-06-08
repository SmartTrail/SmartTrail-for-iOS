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

@property (retain,nonatomic) IBOutlet UILabel*            statsLabel;
@property (retain,nonatomic) IBOutlet UISegmentedControl* segmentedControl;
@property (retain,nonatomic) IBOutlet UIView*             infoView;
@property (retain,nonatomic) IBOutlet UITableView*        conditionView;
@property (retain,nonatomic) IBOutlet UIImageView*        techRatingImageView;
@property (retain,nonatomic) IBOutlet UIImageView*        aerobicRatingImageView;
@property (retain,nonatomic) IBOutlet UIImageView*        coolRatingImageView;
@property (retain,nonatomic) IBOutlet UIWebView*          descriptionWebView;
@property (retain,nonatomic) IBOutlet FetchedResultsTableDataSource*
                                                          conditionsDataSource;
@property (retain,nonatomic) IBOutlet LinkingWebViewDelegate*
                                                          linkingWebViewDelegate;
@property (retain,nonatomic)          Trail*              trail;

- (IBAction) segmentedControlChanged:(id)sender;

@end
