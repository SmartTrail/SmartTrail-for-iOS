//
//  EventDetailViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-25.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EventDetailViewController.h"
#import "TrailDetailViewController.h"
#import "LinkingWebViewDelegate.h"


@implementation EventDetailViewController
@synthesize titleLabel = __titleLabel;
@synthesize dateRangeLabel = __dateRangeLabel;
@synthesize descriptionWebView = __descriptionWebView;
@synthesize linkingWebViewDelegate = __linkingWebViewDelegate;
@synthesize event = __event;




- (void) viewDidUnload {
    self.titleLabel = nil;
    self.dateRangeLabel = nil;
    self.descriptionWebView = nil;
    self.linkingWebViewDelegate = nil;

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


- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ( [segue.identifier isEqualToString:@"TrailDetailSegue"] ) {
        //  User tapped a link in the web view that happens to be a trail.
        TrailDetailViewController* trailDetailCtlr =
            segue.destinationViewController;
        trailDetailCtlr.trail =
            (Trail*)((LinkingWebViewDelegate*)sender).managedObjectForURL;
    }
}


@end
