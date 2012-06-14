//
//  EventsTableViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-23.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventsTableViewController.h"
#import "EventWebClient.h"
#import "EventDetailViewController.h"
#import "AppDelegate.h"


@implementation EventsTableViewController


@synthesize fetchedResultsTableDataSource = __fetchedResultsTableDataSource;


- (id) initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


- (void) viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient {
    return  orient == UIInterfaceOrientationPortrait;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [THE(bmaController) checkEvents];
}


#pragma mark - Table view delegate


- (void)          tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}


#pragma mark - NSFetchedResultsControllerDelegate implementation


- (void) controllerDidChangeContent:(NSFetchedResultsController*)sender {
    //  Some managed object known by the results controller has been added,
    //  removed, moved, or updated.
    [self.tableView reloadData];
}


- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"showEventDetail"] ) {
        EventDetailViewController* detailCtlr = segue.destinationViewController;
        Event* selectedEvent = [self.fetchedResultsTableDataSource.fetchedResults
            objectAtIndexPath:self.tableView.indexPathForSelectedRow
        ];
        detailCtlr.event = selectedEvent;
    }
}


@end
