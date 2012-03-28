//
//  EventDetailViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventDetailViewController.h"


@implementation EventDetailViewController
@synthesize titleLabel = __titleLabel;
@synthesize dateRangeLabel = __dateRangeLabel;
@synthesize descriptionWebView = __descriptionWebView;
@synthesize event = __event;


- (void)dealloc {
    [__titleLabel release];         __titleLabel = nil;
    [__dateRangeLabel release];     __dateRangeLabel = nil;
    [__descriptionWebView release]; __descriptionWebView = nil;
    [__event release];              __event = nil;

    [super dealloc];
}


- (id) initWithNibName:(NSString*)nibNameOrNil
                bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        // Custom initialization
    }
    return  self;
}


- (void) viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


- (void) viewDidUnload {
    [self setTitleLabel:nil];
    [self setDateRangeLabel:nil];
    [self setDescriptionWebView:nil];

    [super viewDidUnload];
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.titleLabel.text = self.event.name;

    self.dateRangeLabel.text = [self.event dateRangeString];

    //  Render the description of the event, which is HTML.
    //
    NSString* bmaBaseUrl = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"BmaBaseUrl"
    ];
    [self.descriptionWebView
        loadHTMLString:self.event.descriptionFull
               baseURL:[NSURL URLWithString:bmaBaseUrl]
    ];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient {
    return  orient == UIInterfaceOrientationPortrait;
}


@end
