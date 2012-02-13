//
//  FirstViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2011-12-10.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FirstViewController.h"
#import "BMAAreaDescriptor.h"
#import "BMATrailDescriptor.h"

@implementation FirstViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) bmaWebClient : (BMAWebClient*) webClient didCompleteLogin : (BOOL) successfully
{
    NSLog(@"Got %@ login completion event.", successfully ? @"successful" : @"unsuccessful");
    [webClient logOutOfBmaWebSiteAsync];
}

- (void) bmaAreaDescriptorsWebClient : (BMAAreaDescriptorsWebClient*) webClient didCompleteAreaRetrieval : (BOOL) successfully withResultArray : (NSArray*) resultArray;
{
    for(BMAAreaDescriptor *bmaAreaDescriptor in resultArray)
    {
        NSLog(@"%@", [bmaAreaDescriptor areaName]);
    }
    
    [webClient setEventNotificationDelegate:nil];
}

- (void) bmaAreaDescriptorWebClient : (BMAAreaDescriptorWebClient*) webClient didCompleteAreaRetrieval : (BOOL) successfully withAreaDescriptor : (BMAAreaDescriptor*) areaDescriptor
{
    NSLog(@"%@", [areaDescriptor areaName]);
    [webClient setEventNotificationDelegate:nil];
}


- (void) bmaTrailDescriptorsWebClient : (BMATrailsDescriptorWebClient*) webClient didCompleteTrailRetrieval : (BOOL) successfully withResultArray : (NSArray*) resultArray
{
    for(BMATrailDescriptor *trailDescriptor in resultArray)
    {
        NSLog(@"%@", trailDescriptor);
    }
    
    [webClient setEventNotificationDelegate:nil];
}

- (void) bmaTrailDescriptorWebClient : (BMATrailDescriptorWebClient*) webClient didCompleteTrailRetrieval : (BOOL) successfully withTrailDescriptor : (BMATrailDescriptor*) trailDescriptor
{
    NSLog(@"%@", trailDescriptor);
    [webClient setEventNotificationDelegate: nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

#if 0
    /*
     Turns out that this web site is not the one we should be using for clients other than
     a browser.
     */
    BMAWebClient *webClient = [[[BMAWebClient alloc] init] autorelease];
    [webClient setEventListener:self];
    [webClient logIntoBmaWebSiteAsync:@"doomer" andPassword:@"pass4John"];
    NSString *sessionCookie = [webClient sessionCookie];
    NSLog(@"%@", sessionCookie);
    [webClient logOutOfBmaWebSiteAsync];
    
    BMAAreaDescriptorsWebClient *areaDescriptorsWebClient = [[[BMAAreaDescriptorsWebClient alloc] init] autorelease];
    [areaDescriptorsWebClient setEventNotificationDelegate:self];
    [areaDescriptorsWebClient getAreaDescriptorsForRegion:1];
    
    BMAAreaDescriptorWebClient *areaDescriptorWebClient = [[[BMAAreaDescriptorWebClient alloc] init] autorelease];
    [areaDescriptorWebClient setEventNotificationDelegate:self];
    [areaDescriptorWebClient getAreaDescriptorForArea:1];
    
    BMATrailsDescriptorWebClient *trailsDescriptorWebClient = [[[BMATrailsDescriptorWebClient alloc] init] autorelease];
    [trailsDescriptorWebClient setEventNotificationDelegate:self];
    [trailsDescriptorWebClient getTrailsDescriptorForArea:1];
    
    BMATrailDescriptorWebClient *trailDescriptorWebClient = [[[BMATrailDescriptorWebClient alloc] init] autorelease];
    [trailDescriptorWebClient setEventNotificationDelegate:self];
    [trailDescriptorWebClient getTrailDescriptorForTrail:217];
#endif
 
    BMATrailsDescriptorWebClient *trailsDescriptorWebClient = [[[BMATrailsDescriptorWebClient alloc] init] autorelease];
    [trailsDescriptorWebClient setEventNotificationDelegate:self];
    [trailsDescriptorWebClient getTrailsDescriptorForRegion:1];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
