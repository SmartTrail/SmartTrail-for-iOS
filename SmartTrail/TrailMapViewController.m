//
// Created by tyler on 2012-07-20.
//


#import "TrailMapViewController.h"
#import "KMLParser.h"


@implementation TrailMapViewController
{
    KMLParser* kmlParser;
}


@synthesize mapView = __mapView;
@synthesize trail = __trail;


- (void)viewDidLoad {
    [super viewDidLoad];
    //  For some reason, you can't set this in IB:
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    if ( self.trail.kmlDirPath ) {
    }

NSLog( @"The %@ did load.", [self class] );                     // DEBUG
}


- (void) viewDidUnload {
NSLog( @"The %@ did unload.", [self class] );                   // DEBUG
    [super viewDidUnload];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient {
    return  orient == UIInterfaceOrientationPortrait;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
NSLog( @"The %@ will appear.", [self class] );                  // DEBUG
}


#pragma mark - Partial implementation of protocol MKMapViewDelegate


- (MKOverlayView*)
           mapView:(MKMapView*)mapView
    viewForOverlay:(id<MKOverlay>)overlay
{
    return  nil;
}


- (MKAnnotationView*)
              mapView:(MKMapView*)mapView
    viewForAnnotation:(id<MKAnnotation>)annotation
{
    return  nil;
}


@end
