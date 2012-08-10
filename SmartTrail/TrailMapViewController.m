//
// Created by tyler on 2012-07-20.
//


#import "TrailMapViewController.h"
#import "KMLParser.h"

static const CGFloat TrailColorRGBA[4] = {0.9569, 0.4824, 0.1255, 1.0};
static const CGFloat TrailLineWidth = 3.0;  // Width in points.


@implementation TrailMapViewController
{
    MKPolylineView* __polylineView;
}


@synthesize mapView = __mapView;
@synthesize trail = __trail;


- (void)viewDidLoad {
    [super viewDidLoad];
    //  For some reason, you can't set this in IB:
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;

    if ( self.trail.kmlDirPath ) {
        KMLParser* kmlParser = [[KMLParser alloc]
            initWithURL:[[NSURL fileURLWithPath:self.trail.kmlDirPath]
                            URLByAppendingPathComponent:@"doc.kml"
                        ]
        ];
        if ( [kmlParser doParse] ) {
            __polylineView = [kmlParser trackOverlayView];
            __polylineView.lineWidth = TrailLineWidth;
            __polylineView.strokeColor = [UIColor
                colorWithRed:TrailColorRGBA[0]
                       green:TrailColorRGBA[1]
                        blue:TrailColorRGBA[2]
                       alpha:TrailColorRGBA[3]
            ];
            [self.mapView addOverlay:__polylineView.overlay];
            self.mapView.visibleMapRect = __polylineView.overlay.boundingMapRect;
            self.mapView.delegate = self;

        } else{
            NSAssert( NO, @"KMLParser could not parse file %@", kmlParser.url );
        }
    }
}


- (void) viewDidUnload {
    self.mapView = nil;
    [super viewDidUnload];
}


- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orient {
    return  orient == UIInterfaceOrientationPortrait;
}


#pragma mark - Partial implementation of protocol MKMapViewDelegate


- (MKOverlayView*)
           mapView:(MKMapView*)mapView
    viewForOverlay:(id<MKOverlay>)overlay
{
    return  __polylineView;
}


- (MKAnnotationView*)
              mapView:(MKMapView*)mapView
    viewForAnnotation:(id<MKAnnotation>)annotation
{
    return  nil;
}


@end
