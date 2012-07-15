//
//  TrailDetailViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrailDetailViewController.h"
#import "AppDelegate.h"
#import "ConditionTableViewCell.h"
#import "UILabel+Utils.h"

@interface TrailDetailViewController ()
- (void) showViewForIndex:(NSUInteger)idx;
- (void) toggleCellForIndexPath:(NSIndexPath*)idxPath toHeight:(CGFloat)hght;
@end


@implementation TrailDetailViewController
{
    //  These two ivars maintain the views selected by the Segmented Control
    //  (radio buttons).
    NSArray*     __viewsToSelect;
    NSUInteger   __selectedViewIndex;

    //  These two ivars maintain the height of the cell to be expanded, if any,
    //  and the index of its row in the table view.
    NSIndexPath* __expandedCellIndexPath;
    CGFloat      __expandedCellHeight;
}


@synthesize statsLabel = __statsLabel;
@synthesize segmentedControl = __segmentedControl;
@synthesize infoView = __infoView;
@synthesize conditionView = __conditionView;
@synthesize techRatingImageView = __techRatingImageView;
@synthesize aerobicRatingImageView = __aerobicRatingImageView;
@synthesize coolRatingImageView = __coolRatingImageView;
@synthesize descriptionWebView = __descriptionWebView;
@synthesize conditionsDataSource = __conditionsDataSource;
@synthesize linkingWebViewDelegate = __linkingWebViewDelegate;
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
        arrayWithObjects:self.infoView, self.conditionView, nil
    ];
    __selectedViewIndex = 0;     // Initially show infoView.
}


- (void)viewDidUnload {
    self.statsLabel = nil;
    self.segmentedControl = nil;
    self.infoView = nil;
    self.conditionView = nil;
    self.techRatingImageView = nil;
    self.aerobicRatingImageView = nil;
    self.coolRatingImageView = nil;
    self.descriptionWebView = nil;
    self.conditionsDataSource = nil;
    self.linkingWebViewDelegate = nil;

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

    //  Tell the data source for the table of conditions which trail we're
    //  viewing, so it can generate the list of Condition objects for it.
    self.conditionsDataSource.templateSubstitutionVariables = [NSDictionary
        dictionaryWithObject:self.trail.id forKey:@"id"
    ];

    //  Update the list of all conditions for trails in this trail's area,
    //  if they have not already been updated recently.
    [THE(bmaController) checkConditionsForArea:self.trail.area];
}


#pragma mark - Actions


/** Action triggered by the Segmented Control (radio buttons). Just reveal the
    view corresponding to the selected segment.
*/
- (IBAction) segmentedControlChanged:(id)sender {
    [self showViewForIndex:(NSUInteger)[sender selectedSegmentIndex]];
}


#pragma mark - UITableViewDelegate implementation for the table of conditions


- (NSIndexPath*)
                   tableView:(UITableView*)tableView
    willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    //  Set of indexes of rows whose cells will change their height. The given
    //  indexPath will not be nil, but expandedCellIndexPath will be nil if no
    //  other cell is expanded. Also, expandedCellIndexPath may be the same as
    //  indexPath, hence the use of an NSSet.
    NSSet* changingCellIndexes = [NSSet
        setWithObjects:indexPath, __expandedCellIndexPath, nil
    ];

    //  Record the at-most-one cell to be expanded in height.
    ConditionTableViewCell* cell = (ConditionTableViewCell*)[tableView
        cellForRowAtIndexPath:indexPath
    ];
    [self
        toggleCellForIndexPath:indexPath
                      toHeight:(   cell.bounds.size.height
                               +   [cell.commentLabel moreHeightWanted]
                               )
    ];

    //  Reload the one or two rows whose cells have changed height.
    [self.conditionView
        reloadRowsAtIndexPaths:[changingCellIndexes allObjects]
              withRowAnimation:UITableViewRowAnimationNone
    ];

    return  indexPath;
}


- (CGFloat)
                  tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    return  [indexPath isEqual:__expandedCellIndexPath]
    ?   __expandedCellHeight            // New height of selected row.
    :   self.conditionView.rowHeight;   // Default for all other rows.
}


#pragma mark - NSFetchedResultsControllerDelegate implementation for the table of conditions


- (void) controllerDidChangeContent:(NSFetchedResultsController*)sender {
    //  Some managed object known by the results controller has been added,
    //  removed, moved, or updated.
    [self.conditionView reloadData];
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


/** Record the new height of the single cell to be expanded in the table of
    conditions, along with the index of its row. The stored data will be
    accessed by the table view when it calls the
    tableView:heightForRowAtIndexPath: delegate method.
*/
- (void) toggleCellForIndexPath:(NSIndexPath*)idxPath toHeight:(CGFloat)hght {
    __expandedCellIndexPath =
        [idxPath isEqual:__expandedCellIndexPath]  ?  nil  :  idxPath;
    __expandedCellHeight = hght;
}


@end
