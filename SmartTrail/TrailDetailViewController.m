//
//  TrailDetailViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-16.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrailDetailViewController.h"
#import "AppDelegate.h"
#import "CollectionUtils.h"

@interface TrailDetailViewController ()
- (void) transitionToVCNumber:(NSUInteger)idx;
@end


@implementation TrailDetailViewController
{
    //  These two ivars maintain the views selected by the Segmented Control
    //  (radio buttons). Variable __selectedViewControllerIndex is needed to
    //  remember the selection even after self.view has been unloaded. It is
    //  initially 0.
    NSArray*   __viewControllersToSelect;
    NSUInteger __selectedViewControllerIndex;
    NSUInteger __mapIndex;
}


@synthesize segmentedControl = __segmentedControl;
@synthesize contentView = __contentView;
@synthesize trail = __trail;


#pragma mark - View lifecycle


- (void) viewDidLoad {
    [super viewDidLoad];

    //  Set up the collection of views to select using the segmented controller.
    __viewControllersToSelect = [NSArray arrayWithObjects:
        [self.storyboard instantiateViewControllerWithIdentifier:@"TrailInfo"],
        [self.storyboard instantiateViewControllerWithIdentifier:@"TrailConditions"],
        [self.storyboard instantiateViewControllerWithIdentifier:@"TrailMap"],
        nil
    ];
    __mapIndex = 2;

    //  Initial selected index of the segmented control can be set in IB.
    __selectedViewControllerIndex = self.segmentedControl.selectedSegmentIndex;
    [self transitionToVCNumber:__selectedViewControllerIndex];
}


- (void) viewDidUnload {
    self.segmentedControl = nil;
    self.contentView = nil;
    [super viewDidUnload];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

if ( self.trail.kmzURL )  NSLog( @"Checking KMZ URL %@.", self.trail.kmzURL );
else  NSLog( @"No KMZ URL to download.");

    [self setMapEnabled:NO];

    //  Initiate download of trail's KMZ data, if necessary.
    [THE(bmaController)
        checkKMZForTrail:self.trail
                  thenDo:^(NSURL* url) {
                             NSString* newPath = [[url absoluteURL] path];
                             if ( ! [newPath isEqual:self.trail.kmlDirPath] ) {
                                 self.trail.kmlDirPath = newPath;
                                 [THE(dataUtils) save];
                             }
                             [self setMapEnabled:YES];
NSLog( @"Using uzipped KML dir. %@", url );
                         }
    ];

    //  Update the list of all conditions for trails in this trail's area,
    //  if they have not already been updated recently.
    [THE(bmaController) checkConditionsForArea:self.trail.area];

    [__viewControllersToSelect each:^(id vc){ [vc setTrail:self.trail]; }];

    //  Show trail name at top of screen.
    self.navigationItem.title = self.trail.name;
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    // Return YES for supported orientations
    return (orient == UIInterfaceOrientationPortrait);
}


#pragma mark - Actions


/** Action triggered by the Segmented Control (radio buttons). Just reveal the
    view corresponding to the selected segment.
*/
- (IBAction) segmentedControlChanged:(id)sender {
    [self transitionToVCNumber:(NSUInteger)[sender selectedSegmentIndex]];
}


#pragma mark - Private methods and functions


- (void) setMapEnabled:(BOOL)enabled {
    [self.segmentedControl
               setEnabled:enabled
        forSegmentAtIndex:__mapIndex
     ];
}


/** Replace the existing child view controller and its view, if any, with the
    one at index idx of array __viewControllersToSelect. The first time this is
    called, there will be no child, so the indicated view controller is simply
    added, and its view is added to the receiver's view in a frame equal to that
    of the view in outlet contentView. (That view is used only for its frame!)
    On subsequent calls, the replacement will be presented with an animated
    transition. We assume that this method is never called with idx ==
    __selectedViewControllerIndex.

    This view controller dance is done so they will receive correct delegate
    calls by the system. That way, you can work on a child view controller class
    without much concern about details of the other controllers.
*/
- (void) transitionToVCNumber:(NSUInteger)idx {

    UIViewController* selectedVC = [__viewControllersToSelect objectAtIndex:idx];
    UIViewController* deselectedVC = [__viewControllersToSelect
        objectAtIndex:__selectedViewControllerIndex
    ];
    BOOL haveAChild = (BOOL)[self.childViewControllers count];

    //  Need to tell selectedVC it will be added. Automatically calls
    //  willMoveToParentViewController:
    [self addChildViewController:selectedVC];
    //  Make sure the view has the right size and position.
    selectedVC.view.frame = self.contentView.frame;

    if ( ! haveAChild) {
        //  Add selectedVC's view to the view heirarchy and notify we did it.
        [self.contentView addSubview:selectedVC.view];
        [selectedVC didMoveToParentViewController:self];

    } else {
        //  Need to tell deselectedVC it will be removed. This method really
        //  should be named "willMoveToOrFromParentViewController:". Go figure!
        [deselectedVC willMoveToParentViewController:self];

        //  Swap the views in and out of the view heirarchy.
        [self
            transitionFromViewController:deselectedVC
                        toViewController:selectedVC
                                duration:0.5
                                 options:UIViewAnimationOptionTransitionCrossDissolve
                              animations:^(){ /* Change props. to animate. */ }
                              completion:^(BOOL animDone){
                                  //  Done with transition. Remove deselectedVC.
                                  //  (Auto. calls didMoveToParentViewController:.)
                                  [deselectedVC removeFromParentViewController];
                                  //  Notify selectedVC that we're done.
                                  [selectedVC didMoveToParentViewController:self];
                              }
        ];
    }

    __selectedViewControllerIndex = idx;
}


@end
