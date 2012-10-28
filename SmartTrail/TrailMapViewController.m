//
// Created by tyler on 2012-07-20.
//


#import "TrailMapViewController.h"
#import "TrailPolylineOverlay.h"
#import "AppDelegate.h"

static const CGFloat TrailColorRGBA[4] = {0.9569, 0.4824, 0.1255, 1.0};
static const CGFloat TrailLineWidth = 3.0;  // Width in points.


@implementation TrailMapViewController
{
    TrailPolylineOverlay* __overlay;
}


@synthesize mapView = __mapView;
@synthesize trail = __trail;


- (void) parseKMLDataIfOkDo:(void (^)())block {
    NSAssert( self.trail, @"You must assign the trail property before calling checkKMZ." );

    //  Initiate download of trail's KMZ data, if necessary.
    [THE(bmaController)
        checkKMZForTrail:self.trail
                 thenOnQ:dispatch_get_main_queue()
                      do:^(NSURL* url, BOOL fresh) {
            if (fresh) {
                //  We have newly downloaded data, so we may need
                //  to update the trail and persist it.
                NSString* newPath = [[url absoluteURL] path];
                if (![newPath isEqual:self.trail.kmlDirPath]) {
                    self.trail.kmlDirPath = newPath;
                    [THE(dataUtils) save];
                }
            }

            if ( self.trail.kmlDirPath ) {
                //  Map data should exist for this trail. Parse it.
                __overlay = [[TrailPolylineOverlay alloc]
                  initWithTrail:self.trail
                ];

                if ( [__overlay updateTrail:self.trail] ) {
                    [THE(dataUtils) save];

                    //  A-OK. Go ahead and perform the caller's task.
                    block();
                }
            }
        }
    ];
}


- (void) viewDidLoad {
    [super viewDidLoad];

    //  Need to configure mapView in code below anyway, so might as well
    //  assign its delegate here rather than in IB.
    self.mapView.delegate = self;
    //  For some reason, you can't set this in IB:
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    //  If parseKMLDataIfOkDo: has already been called, then we just need to
    //  add the __overlay to mapView and assign the visibleMapRect. Otherwise,
    //  first parse, then do it. Note that all this is done serially in the main
    //  queue. Note also that __overlay will be non-nil even if the parse was
    //  unsuccessful, and it is added to the map view anyway. But that's OK,
    //  since the map view handles the nil boundingMapRect (showing a map of the
    //  entire world).
    //
    void (^addOverlayToMapView)() = ^{
        [self.mapView addOverlay:__overlay];
        self.mapView.visibleMapRect = __overlay.boundingMapRect;
    };
    if ( __overlay )  addOverlayToMapView();
    else  [self parseKMLDataIfOkDo:addOverlayToMapView];
}


- (void) viewDidUnload {
    self.mapView.delegate = nil;
    self.mapView = nil;
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
