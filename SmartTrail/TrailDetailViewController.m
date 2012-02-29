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
@property (retain,nonatomic) NSArray* viewsToSelect;
@property (nonatomic) NSUInteger selectedViewIndex;
- (void) showViewForIndex:(NSUInteger)idx;
@end


@implementation TrailDetailViewController


@synthesize statsView = __statsView;
@synthesize trailLengthLabel = __trailLengthLabel;
@synthesize trailElevationGainLabel = __trailElevationGainLabel;
@synthesize segmentedControl = __segmentedControl;
@synthesize infoView = __infoView;
@synthesize conditionView = __conditionView;
@synthesize techRatingImageView = __techRatingImageView;
@synthesize aerobicRatingImageView = __aerobicRatingImageView;
@synthesize coolRatingImageView = __coolRatingImageView;
@synthesize descriptionWebView = __descriptionWebView;
@synthesize trail = __trail;
@synthesize viewsToSelect = __viewsToSelect;
@synthesize selectedViewIndex = __selectedViewIndex;


- (void) dealloc {
    [__statsView release];               __statsView = nil;
    [__trailLengthLabel release];        __trailLengthLabel = nil;
    [__trailElevationGainLabel release]; __trailElevationGainLabel = nil;
    [__segmentedControl release];        __segmentedControl = nil;
    [__infoView release];                __infoView = nil;
    [__conditionView release];           __conditionView = nil;
    [__techRatingImageView release];     __techRatingImageView = nil;
    [__aerobicRatingImageView release];  __aerobicRatingImageView = nil;
    [__coolRatingImageView release];     __coolRatingImageView = nil;
    [__descriptionWebView release];      __descriptionWebView = nil;
    [__trail release];                   __trail = nil;
    [__viewsToSelect release];           __viewsToSelect = nil;
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        self.selectedViewIndex = 0;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewsToSelect = [NSArray
        arrayWithObjects:self.infoView, self.conditionView, nil
    ];
}


- (void)viewDidUnload {
    self.statsView = nil;
    self.trailLengthLabel = nil;
    self.trailElevationGainLabel = nil;
    self.segmentedControl = nil;
    self.techRatingImageView = nil;
    self.aerobicRatingImageView = nil;
    self.coolRatingImageView = nil;
    self.infoView = nil;
    self.conditionView = nil;
    self.descriptionWebView = nil;
    
    [super viewDidUnload];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient
{
    // Return YES for supported orientations
    return (orient == UIInterfaceOrientationPortrait);
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //  Show trail name at top of screen.
    //
    self.navigationItem.title = self.trail.name;

    //  Show trail length and elevation gain if we have data.
    //
    if ( self.trail.length.floatValue > 0.0 ) {
        self.statsView.hidden = NO;
        self.trailLengthLabel.text = [NSString
            stringWithFormat:@"%.1f", self.trail.length.floatValue
        ];
        self.trailElevationGainLabel.text = [NSString
            stringWithFormat:@"%d", self.trail.elevationGain.intValue
        ];
    } else {
        self.statsView.hidden = YES;
    }

    //  Show or hide info or condition views.
    //
    self.segmentedControl.selectedSegmentIndex = self.selectedViewIndex;
    [self showViewForIndex:self.selectedViewIndex];

    //  Draw the rating dots.
    //
    self.techRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.techRating.longValue
    ];
    self.aerobicRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.aerobicRating.longValue
    ];
    self.coolRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.coolRating.longValue
    ];

    //  Render the description of the trail, which is HTML.
    //
    NSString* bmaBaseUrl = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"BmaBaseUrl"
    ];
    [self.descriptionWebView
        loadHTMLString:self.trail.descriptionFull
               baseURL:[NSURL URLWithString:bmaBaseUrl]
    ];
}


#pragma mark - Event handlers


- (IBAction) segmentedControlChanged:(id)sender {
    [self showViewForIndex:(NSUInteger)[sender selectedSegmentIndex]];
}


#pragma mark - Private methods and functions


- (void) showViewForIndex:(NSUInteger)idx {
    UIView* selectedView = [self.viewsToSelect objectAtIndex:idx];
    UIView* deSelectedView = [self.viewsToSelect
        objectAtIndex:self.selectedViewIndex
    ];

    deSelectedView.hidden = YES;
    selectedView.hidden = NO;

    self.selectedViewIndex = idx;
}


@end
