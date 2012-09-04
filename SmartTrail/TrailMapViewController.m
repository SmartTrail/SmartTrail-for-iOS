//
// Created by tyler on 2012-07-20.
//


#import "TrailMapViewController.h"
#import "TrailPolylineOverlay.h"
#import "AppDelegate.h"

static const CGFloat TrailColorRGBA[4] = {0.9569, 0.4824, 0.1255, 1.0};
static const CGFloat TrailLineWidth = 3.0;  // Width in points.


@implementation TrailMapViewController


@synthesize mapView = __mapView;
@synthesize trail = __trail;


- (void) viewDidLoad {
    [super viewDidLoad];

    //  Need to configure mapView in code below anyway, so might as well
    //  assign its delegate here rather than in IB.
    self.mapView.delegate = self;
    //  For some reason, you can't set this in IB:
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    if ( self.trail.kmlDirPath ) {
        //  Map data should exist for this trail. Parse and display it.

        TrailPolylineOverlay* overlay = [[TrailPolylineOverlay alloc]
            initWithTrail:self.trail
        ];
NSLog( @"Created overlay %@", overlay );
        [self.mapView addOverlay:overlay];
        self.mapView.visibleMapRect = overlay.boundingMapRect;
    }
}


- (void) viewDidUnload {
    self.mapView = nil;
    self.mapView.delegate = nil;
    [super viewDidUnload];
}


- (void) viewDidDisappear:(BOOL)animated {
    //  If map dimensions were not yet available in self.trail, then KML data
    //  was parsed and those fields were assigned values. So persist changes.
    if ( [self.trail hasChanges] )  [THE(dataUtils) save];

    [super viewDidDisappear:animated];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient {
    return  orient == UIInterfaceOrientationPortrait;
}


#pragma mark - Partial implementation of protocol MKMapViewDelegate


- (MKOverlayView*)
           mapView:(MKMapView*)mapView
    viewForOverlay:(id<MKOverlay>)overlay
{
NSLog( @"Creating view for overlay %@", overlay );
    MKPolylineView* v = [[MKPolylineView alloc] initWithPolyline:(MKPolyline*)overlay];
    v.lineWidth = TrailLineWidth;
    v.strokeColor = [UIColor
        colorWithRed:TrailColorRGBA[0]
               green:TrailColorRGBA[1]
                blue:TrailColorRGBA[2]
               alpha:TrailColorRGBA[3]
    ];
    return  v;
}


@end
