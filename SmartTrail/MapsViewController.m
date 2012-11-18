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
#import "TrailDetailViewController.h"


@interface ButtonTarget : NSObject
@property (readonly,nonatomic) NSString* trailId;
- (id) initWithController:(MapsViewController*)c trailId:(NSString*)t;
- (void) actionForButton:(id)sender;
@end


@implementation MapsViewController
{
    NSMutableDictionary* __targetsByTrailId;
}


- (void) viewDidLoad {
    [super viewDidLoad];
    __targetsByTrailId = [NSMutableDictionary new];

	[THE(bmaController)
        checkAllKMZsThenOnQ:dispatch_get_main_queue()
                         do:
        ^(NSArray* allTrails, CoreDataUtils* utils) {
            MKMapRect unionRect = MKMapRectNull;

            //  For each trail, if it has a map, create an annotation for it.
            //  Also populate __targetsByTrailId, for use by
            //  mapView:viewForAnnotation:.
            //
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

                    [__targetsByTrailId
                        setObject:[[ButtonTarget alloc]
                                      initWithController:self
                                                 trailId:trail.id
                                  ]
                           forKey:trail.id
                    ];
                }
            }
            [utils save];
            self.mapView.visibleMapRect = unionRect;
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
    NSString* trailId = ((TrailPolylineOverlay*)annotation).trailId;
    NSString* reuseId = @"MAPS_ANNOTATIONS";
    MKPinAnnotationView* pinView;
    UIButton* detailBtn;

    pinView = (MKPinAnnotationView*)[self.mapView
        dequeueReusableAnnotationViewWithIdentifier:reuseId
    ];
    if ( pinView ) {
        pinView.annotation = annotation;

        //  The pinView already has a button to bring up trail detail, so just
        //  need to reconfigure its target with the annotation's trail id.
        detailBtn = (UIButton*)pinView.rightCalloutAccessoryView;
        [detailBtn
                removeTarget:[[detailBtn allTargets] anyObject]
                      action:@selector(actionForButton:)
            forControlEvents:UIControlEventTouchUpInside
        ];

    } else {
        pinView = [[MKPinAnnotationView alloc]
            initWithAnnotation:annotation reuseIdentifier:reuseId
        ];
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.animatesDrop = NO;
        pinView.canShowCallout = YES;

        detailBtn = [UIButton
            buttonWithType:UIButtonTypeDetailDisclosure
        ];
        pinView.rightCalloutAccessoryView = detailBtn;
    }

    [detailBtn
               addTarget:[__targetsByTrailId objectForKey:trailId]
                  action:@selector(actionForButton:)
        forControlEvents:UIControlEventTouchUpInside
    ];

    return  pinView;
}


/** Transition to the trail detail screen.
*/
- (void) prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    if ( [[segue identifier] isEqual:@"MapsToTrailDetail"] ) {
        TrailDetailViewController* detailCtlr = segue.destinationViewController;
        Trail* trail = (Trail*)[THE(dataUtils)
            findThe:@"TrailForId"
                 at:((ButtonTarget*)sender).trailId
        ];
        detailCtlr.trail = trail;
        detailCtlr.initialSegmentIndex = MAP_SEGMENT_IDX;
    }
}


@end


@implementation ButtonTarget
{
    MapsViewController* __controller;
}


@synthesize trailId = __trailId;


- (id) initWithController:(MapsViewController*)c trailId:(NSString*)t {
    self = [super init];
    if ( self ) {
        __controller = c;
        __trailId = t;
    }
    return  self;
}


- (void) actionForButton:(id)sender {
    [__controller performSegueWithIdentifier:@"MapsToTrailDetail" sender:self];
}


@end
