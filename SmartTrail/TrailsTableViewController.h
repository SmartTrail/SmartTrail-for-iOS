//
//  TrailsTableViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FetchedResultsTableDataSource.h"


@interface TrailsTableViewController :
    UITableViewController<NSFetchedResultsControllerDelegate>

@property (nonatomic) IBOutlet
    FetchedResultsTableDataSource* fetchedResultsTableDataSource;

@end
