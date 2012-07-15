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


@synthesize statsLabel = __statsLabel;
@synthesize segmentedControl = __segmentedControl;
@synthesize infoView = __infoView;
@synthesize techRatingImageView = __techRatingImageView;
@synthesize aerobicRatingImageView = __aerobicRatingImageView;
@synthesize coolRatingImageView = __coolRatingImageView;
@synthesize descriptionWebView = __descriptionWebView;
@synthesize linkingWebViewDelegate = __linkingWebViewDelegate;
@synthesize trailConditionsController = __trailConditionsController;
@synthesize trail = __trail;


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    //  Set up the collection of views to select using the segmented controller.
    __viewsToSelect = [NSArray
        arrayWithObjects:self.infoView, self.trailConditionsController.tableView, nil
    ];
    __selectedViewIndex = 0;     // Initially show infoView.
}


- (void)viewDidUnload {
    self.statsLabel = nil;
    self.segmentedControl = nil;
    self.infoView = nil;
    self.techRatingImageView = nil;
    self.aerobicRatingImageView = nil;
    self.coolRatingImageView = nil;
    self.descriptionWebView = nil;
    self.linkingWebViewDelegate = nil;
    self.trailConditionsController = nil;

    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    // Return YES for supported orientations
    return (orient == UIInterfaceOrientationPortrait);
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //  Initiate download of trail's KMZ data, if necessary.
    [THE(bmaController)
        checkKMZForTrail:self.trail
                  thenDo:^(NSURL* url) {
                             self.trail.kmlDirPath = [[url absoluteURL] path];
NSLog( @"Downloaded %@", self.trail.kmlDirPath );
                         }
    ];

    //  Update the list of all conditions for trails in this trail's area,
    //  if they have not already been updated recently.
    [THE(bmaController) checkConditionsForArea:self.trail.area];

    //  Inform the conditions table's controller which trail we're examining.
    self.trailConditionsController.trail = self.trail;

    //  Show trail name at top of screen.
    self.navigationItem.title = self.trail.name;

    //  Show trail length and elevation gain if we have data.
    self.statsLabel.text =  self.trail.length.floatValue > 0.0
    ?   [NSString
            stringWithFormat:@"%.1f miles    gain: %d feet",
                self.trail.length.floatValue,
                self.trail.elevationGain.intValue
        ]
    :   @"";

    //  Show or hide info or condition views.
    self.segmentedControl.selectedSegmentIndex = __selectedViewIndex;
    [self showViewForIndex:__selectedViewIndex];

    //  Draw the rating dots.
    self.techRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.techRating.longValue inRange:0 through:10
    ];
    self.aerobicRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.aerobicRating.longValue inRange:0 through:10
    ];
    self.coolRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.coolRating.longValue inRange:0 through:10
    ];

    //  Render the description of the trail, which is HTML.
    NSString* bmaBaseUrl = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"BmaBaseUrl"
    ];
    [self.descriptionWebView
        loadHTMLString:self.trail.descriptionFull
               baseURL:[NSURL URLWithString:bmaBaseUrl]
    ];
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
