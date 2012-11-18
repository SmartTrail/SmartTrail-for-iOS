//
// Created by tyler on 2012-08-21.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TrailPolylineOverlay.h"
#import "KMLParser.h"
#import "Trail+Mapping.h"
#import "Area.h"

@interface TrailPolylineOverlay ()
@property (strong,nonatomic) MKPolyline* polyline;
- (BOOL) checkTrailMapDimensions;
CLLocation* locationByInterpolatingBack(
    CLLocationDistance negPortion, CLLocation* beg, CLLocation* end
);
double interpolateBack( double portion, double beg, double end );
@end

CLLocationCoordinate2D EquatorAtPrimeMeridian = {(double)0.0, (double)0.0};


@implementation TrailPolylineOverlay


{
    NSString* __trail_kmlDirPath;
    CLLocationCoordinate2D __trail_mapCoordinate;
    MKMapRect __trail_boundingMapRect;
    NSObject* __dummy;
}
@synthesize trailId = __trailId;
@synthesize trackLocations = __trackLocations;
@synthesize trackLength = __trackLength;
@synthesize title = __title;
@synthesize subtitle = __subtitle;
@synthesize polyline = __polyline;


#pragma mark - Methods an NSProxy subclass must implement


- (id) initWithTrail:(Trail*)t {
    //  (Superclass NSProxy is abstract, so must not [super init] and self OK.)
    if ( t.kmlDirPath ) {
        __trailId = t.id;
        __trail_kmlDirPath = t.kmlDirPath;
        __trail_mapCoordinate = t.mapCoordinate;
        __trail_boundingMapRect = t.boundingMapRect;
        if (
            MKMapRectIsNull(__trail_boundingMapRect)    ||  // Check origin
            __trail_boundingMapRect.size.width  <= 0.0  ||  //   and size.
            __trail_boundingMapRect.size.height <= 0.0      //
        ) {
            __trail_boundingMapRect = MKMapRectNull;
        }

        __title = t.name;
        __subtitle = t.area.name;

        __trackLength = -1.0;

        //  __dummy just needs to implement methodSignatureForSelector:.
        __dummy = [NSObject new];

    } else {
        NSAssert( t.kmlDirPath, @"The given Trail's kmlDirPath is nil." );
        self = nil;
    }
    return  self;
}


- (BOOL) updateTrail:(Trail*)t {
  BOOL mapOk = [self checkTrailMapDimensions];
  if ( mapOk ) {

    if ( ! [t.id isEqualToString:self.trailId] ) {
        NSAssert(
            NO,
            @"The given Trail (id: %@) must refer to the same data given to the initializer (id: %@).",
            t.id, self.trailId
        );

    } else{
        if (
            t.mapCoordLat.doubleValue   != __trail_mapCoordinate.latitude  ||
            t.mapCoordLon.doubleValue   != __trail_mapCoordinate.longitude
        )  t.mapCoordinate = __trail_mapCoordinate;
        if (
            t.mapRectX.doubleValue      != __trail_boundingMapRect.origin.x   ||
            t.mapRectY.doubleValue      != __trail_boundingMapRect.origin.y   ||
            t.mapRectWidth.doubleValue  != __trail_boundingMapRect.size.width ||
            t.mapRectHeight.doubleValue != __trail_boundingMapRect.size.height
        )  t.boundingMapRect = __trail_boundingMapRect;
    }
  }
  return  mapOk;
}


- (void) forwardInvocation:(NSInvocation*)invocation {
    MKPolyline* poly = self.polyline;
    [invocation setTarget:(poly ? poly : __dummy)];
    [invocation invoke];
    return;
}


- (NSMethodSignature*) methodSignatureForSelector:(SEL)selector {
    MKPolyline* poly = self.polyline;
    return  [(poly ? poly : __dummy) methodSignatureForSelector:selector];
}


#pragma mark - Methods dealing with the coordinates of the track


- (NSArray*) trackLocations {
    if ( !__trackLocations ) {
        KMLParser* parser = [[KMLParser alloc]
            initWithDirPath:__trail_kmlDirPath
        ];
        __trackLocations = parser.locations;
    }
    return __trackLocations;
}


- (CLLocationDistance) trackLength {
    if ( __trackLength < 0.0  &&  self.trackLocations ) {
        CLLocation* prevLoc = [self.trackLocations objectAtIndex:0];

        for ( CLLocation* loc in self.trackLocations ) {
            __trackLength += [loc distanceFromLocation:prevLoc];
            prevLoc = loc;
        }
    }
    return  __trackLength;
}


- (CLLocation*) trackInterpolate:(double)portionOfLength {
    CLLocation* interpLoc = nil;

    if ( self.trackLocations ) {        // Note: Cannot be empty if non-nil.

        if ( 0.0 <= portionOfLength  &&  portionOfLength <= 1.0 ) {
            CLLocationDistance toGo = portionOfLength * self.trackLength;
            CLLocation* lastLoc = [self.trackLocations objectAtIndex:0];

            for ( CLLocation* loc in self.trackLocations ) {
                CLLocationDistance distFromLast = [loc
                    distanceFromLocation:lastLoc
                ];
                toGo -= distFromLast;

                if ( toGo <= 0.0 ) {
                    //  We've gone to or just past the portionOfLength point.
                    //  The amount we've gone past is just the negative toGo value.
                    interpLoc = locationByInterpolatingBack(
                        toGo/distFromLast, lastLoc, loc
                    );
                    break;
                }
                lastLoc = loc;
            }

        } else {
            NSAssert(
                NO,
                @"Portion argument must be between 0.0 and 1.0, inclusive, not %f",
                portionOfLength
            );
        }
    }

    return  interpLoc;
}


#pragma mark - Implementation of Protocol MKOverlay


- (CLLocationCoordinate2D) coordinate {
    return  [self checkTrailMapDimensions]
    ?   __trail_mapCoordinate
    :   EquatorAtPrimeMeridian;
}


- (MKMapRect) boundingMapRect {
    return  [self checkTrailMapDimensions]
    ?   __trail_boundingMapRect
    :   MKMapRectNull;
}


/** We may not have map dimensions saved in the trail, in which case this method
    parses the KML file. Or we may already have a polyline. In either case, we
    have polyline data and this method just delegates to the polyline.

    Otherwise we do have map dimensions from the trail, but don't have the
    polyline. In this case we just use the trail's saved boundingMapRect and
    return YES iff it intersects the given rectangle. This is probably less
    precise than the case above, because the polyline can check each of its
    points to see whether it lies in the given mapRect.
*/
- (BOOL) intersectsMapRect:(MKMapRect)mapRect {
    return  (
        [self checkTrailMapDimensions]  &&
        MKMapRectIntersectsRect( __trail_boundingMapRect, mapRect )
    );
}


#pragma mark - Private methods and functions


- (MKPolyline*) polyline {
    //  We will finally parse KML here. The trackLocations getter does it.
    if ( ! __polyline  &&  self.trackLocations ) {

        NSUInteger locationsCount = [self.trackLocations count];
        CLLocationCoordinate2D* buffPtr = malloc(
            sizeof( CLLocationCoordinate2D ) * locationsCount
        );

        [self.trackLocations
            enumerateObjectsUsingBlock:^(id loc, NSUInteger idx, BOOL* stop) {
                buffPtr[idx] = ((CLLocation*)loc).coordinate;
            }
        ];

        //  Copy coordinates in buffPtr into a new MKPolyline object.
        __polyline = [MKPolyline
            polylineWithCoordinates:buffPtr count:locationsCount
        ];
        free( buffPtr );
    }

    return  __polyline;
}


/** Ensures that we have values for the rough dimensions of the trail's track.
    If we already do, this method does no parsing and just returns YES.
    Otherwise, self.polyline is created, if necessary, causing the parse to be
    done, and the dimensions are assigned to appropriate instance variables.
    Returns NO if we don't already have the dimensions and the parse was
    unsuccessful.
*/
- (BOOL) checkTrailMapDimensions {
    if ( MKMapRectIsNull(__trail_boundingMapRect)  &&  self.polyline ) {
        //  We don't have trail map dimensions in the trail managed object, so
        //  we need to parse the KML file. Obtaining polyline does this.
        __trail_boundingMapRect = self.polyline.boundingMapRect;

        //  Set the map coordinate. This is where the annotation view will be
        //  displayed. We make it the point midway along the track.
        __trail_mapCoordinate = [self trackInterpolate:0.5].coordinate;
    }
    return  ! MKMapRectIsNull(__trail_boundingMapRect);
}


/** Interpolate to create a new CLLocation object which is between the given
    beg and end locations by going back from end by the amount
    negPortion*(end-beg) in each dimension. We assume -1.0 <= negPortion <= 0.0.
*/
CLLocation* locationByInterpolatingBack(
    CLLocationDistance negPortion, CLLocation* beg, CLLocation* end
) {
    CLLocationDegrees  lon = interpolateBack(
        negPortion, beg.coordinate.longitude, end.coordinate.longitude
    );
    CLLocationDegrees  lat = interpolateBack(
        negPortion, beg.coordinate.latitude, end.coordinate.latitude
    );
    CLLocationDistance alt = interpolateBack(
        negPortion, beg.altitude, end.altitude
    );
    NSDate* time = [NSDate
        dateWithTimeIntervalSince1970:interpolateBack(
            negPortion,
            [beg.timestamp timeIntervalSince1970],
            [end.timestamp timeIntervalSince1970]
        )
    ];

    return  [[CLLocation alloc]
        initWithCoordinate:CLLocationCoordinate2DMake(lat,lon)
                  altitude:alt
        horizontalAccuracy:end.horizontalAccuracy
          verticalAccuracy:end.verticalAccuracy
                 timestamp:time
    ];
}


double interpolateBack( double portion, double beg, double end ) {
    return  end + portion*(end - beg);
}


@end
