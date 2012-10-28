//
//  MapsViewController.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-10-11.
//
//

#import "MapsViewController.h"
#import "AppDelegate.h"
#import "TrailPolylineOverlay.h"
#import "Trail+Mapping.h"

@interface MapsViewController ()

@end


@implementation MapsViewController


- (id)
    initWithNibName:(NSString*)nibNameOrNil
             bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if ( self ) {
        // Custom initialization
    }
    return self;
}


- (void) viewDidLoad {
    [super viewDidLoad];
NSLog(@"viewDidLoad");
	[THE(bmaController)
        checkAllKMZsThenOnQ:dispatch_get_main_queue()
                         do:
        ^(NSArray* allTrails, CoreDataUtils* utils) {
NSLog(@"    has changes?  (BOOL)%d  Num. trails:  %d", [utils.context hasChanges], [allTrails count]);
            MKMapRect unionRect = MKMapRectNull;

            for ( Trail* trail in allTrails ) {
                TrailPolylineOverlay* overlay = [[TrailPolylineOverlay alloc]
                    initWithTrail:trail
                ];
                if ( [overlay updateTrail:trail] ) {
                    [self.mapView addAnnotation:overlay];
                    unionRect = MKMapRectUnion(
                        unionRect, overlay.boundingMapRect
                    );
                    //  Note how we asked overlay for the trail's boundingMapRect
                    //  instead of asking the trail directly. This is because the
                    //  overlay lazily updates the trail with this data.
                }
NSLog( @"%@, %@:", trail.id, trail.name );
CLLocationCoordinate2D org = MKCoordinateForMapPoint( overlay.boundingMapRect.origin );
NSLog( @"boundingMapRect: lat=%f, lon=%f, width=%f, height=%f", org.latitude, org.longitude, overlay.boundingMapRect.size.width, overlay.boundingMapRect.size.height );
org = MKCoordinateForMapPoint( unionRect.origin );
NSLog( @"      unionRect: lat=%f, lon=%f, width=%f, height=%f\n", org.latitude, org.longitude, unionRect.size.width, unionRect.size.height );
CLLocationCoordinate2D coord = [overlay coordinate];
NSLog(@"       Annotation's coordinate is lat. %f, lon. %f", coord.latitude, coord.longitude);

            }
            [utils save];
            self.mapView.visibleMapRect = unionRect;
NSLog(@"There are %d annotations.", [self.mapView.annotations count]);
CLLocationCoordinate2D lastCoord = [[self.mapView.annotations lastObject] coordinate];
NSLog(@"    The last one's coordinate is lat. %f, lon. %f", lastCoord.latitude, lastCoord.longitude);
        }
    ];
}


- (void) viewDidUnload {
    self.mapView = nil;
    [super viewDidUnload];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (MKAnnotationView*)
              mapView:(MKMapView*)mapView
    viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString* reuseId = @"MAPS_ANNOTATIONS";
    MKPinAnnotationView* pinView;

    pinView = (MKPinAnnotationView*)[self.mapView
        dequeueReusableAnnotationViewWithIdentifier:reuseId
    ];
    if ( pinView ) {
        pinView.annotation = annotation;

    } else {
        pinView = [[MKPinAnnotationView alloc]
            initWithAnnotation:annotation reuseIdentifier:reuseId
        ];
    }
    pinView.pinColor = MKPinAnnotationColorGreen;
    pinView.animatesDrop = YES;
    pinView.canShowCallout = YES;

    return  pinView;
}


@end
