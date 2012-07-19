//
//  TrailDetailViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrailDetailViewController.h"
#import "AppDelegate.h"

@interface TrailDetailViewController ()
- (void) showViewForIndex:(NSUInteger)idx;
@end


@implementation TrailDetailViewController
{
    //  These two ivars maintain the views selected by the Segmented Control
    //  (radio buttons).
    NSArray*     __viewsToSelect;
    NSUInteger   __selectedViewIndex;
}


@synthesize segmentedControl = __segmentedControl;
@synthesize trailInfoController = __trailInfoController;
@synthesize trailConditionsController = __trailConditionsController;
@synthesize trail = __trail;


#pragma mark - View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    //  Set up the collection of views to select using the segmented controller.
    __viewsToSelect = [NSArray arrayWithObjects:
        self.trailInfoController.view,
        self.trailConditionsController.tableView,
        nil
    ];
    __selectedViewIndex = 0;     // Initially show infoView.
}


- (void)viewDidUnload {
    self.segmentedControl = nil;
    self.trailInfoController = nil;
    self.trailConditionsController = nil;

    [super viewDidUnload];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //  Initiate download of trail's KMZ data, if necessary.
if ( self.trail.kmzURL )  NSLog( @"Checking KMZ URL %@.", self.trail.kmzURL );
else  NSLog( @"No KMZ URL to download.");
    [THE(bmaController)
        checkKMZForTrail:self.trail
                  thenDo:^(NSURL* url) {
                             self.trail.kmlDirPath = [[url absoluteURL] path];
if ( url )  NSLog( @"Using uzipped KML dir. %@", url );
else  NSLog( @"Couldn't download & unzip %@", self.trail.kmzURL );
                         }
    ];


    //  Update the list of all conditions for trails in this trail's area,
    //  if they have not already been updated recently.
    [THE(bmaController) checkConditionsForArea:self.trail.area];

    //  Inform the info and conditions controllers which trail we're examining.
    self.trailInfoController.trail = self.trail;
    self.trailConditionsController.trail = self.trail;

    //  Show trail name at top of screen.
    self.navigationItem.title = self.trail.name;

    //  Show or hide info or condition views.
    self.segmentedControl.selectedSegmentIndex = __selectedViewIndex;
    [self showViewForIndex:__selectedViewIndex];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    // Return YES for supported orientations
    return (orient == UIInterfaceOrientationPortrait);
}


#pragma mark - Actions


/** Action triggered by the Segmented Control (radio buttons). Just reveal the
    view corresponding to the selected segment.
*/
- (IBAction) segmentedControlChanged:(id)sender {
    [self showViewForIndex:(NSUInteger)[sender selectedSegmentIndex]];
}


#pragma mark - Private methods and functions


/** Hides the view that is currently showing and un-hides the view at the
    given index in array viewsToSelect.
*/
- (void) showViewForIndex:(NSUInteger)idx {
    UIView* selectedView = [__viewsToSelect objectAtIndex:idx];
    UIView* deSelectedView = [__viewsToSelect
        objectAtIndex:__selectedViewIndex
    ];

    deSelectedView.hidden = YES;
    selectedView.hidden = NO;

    __selectedViewIndex = idx;
}


@end
