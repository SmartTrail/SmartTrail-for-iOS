//
//  TrailsTableViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-15.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrailsTableViewController.h"
#import "TrailDetailViewController.h"


@implementation TrailsTableViewController


@synthesize fetchedResultsTableDataSource = __fetchedResultsTableDataSource;




- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


- (void)viewDidUnload {
    [self setFetchedResultsTableDataSource:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ( [[segue identifier] isEqual:@"showTrailDetail"] ) {
        TrailDetailViewController* detailCtlr = segue.destinationViewController;
        Trail* selectedTrail = [self.fetchedResultsTableDataSource.fetchedResults
            objectAtIndexPath:self.tableView.indexPathForSelectedRow
        ];
        detailCtlr.trail = selectedTrail;
    }
}


#pragma mark - NSFetchedResultsControllerDelegate implementation


- (void) controllerDidChangeContent:(NSFetchedResultsController*)sender {
    //  Some managed object known by the results controller has been added,
    //  removed, moved, or updated.
    [self.tableView reloadData];
}


@end
