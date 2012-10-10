//
// Created by tyler on 2012-08-21.
//

#import "TrailPolylineOverlay.h"
#import "KMLParser.h"
#import "Trail+Mapping.h"

@interface TrailPolylineOverlay ()
@property (strong,nonatomic) MKPolyline* polyline;
- (void) checkTrailMapDimensions;
CLLocation* locationByInterpolatingBack(
    CLLocationDistance negPortion, CLLocation* beg, CLLocation* end
);
double interpolateBack( double portion, double beg, double end );
@end


@implementation TrailPolylineOverlay


{
    NSObject* __dummy;
}
@synthesize trail = __trail;
@synthesize trackLocations = __trackLocations;
@synthesize trackLength = __trackLength;
@synthesize polyline = __polyline;



#pragma mark - Methods an NSProxy subclass must implement


- (id) initWithTrail:(Trail*)t {
    if ( self ) {
        if ( t.kmlDirPath ) {
            __trail = t;
            __trackLength = -1.0;

            //  __dummy just needs to implement methodSignatureForSelector:.
            __dummy = [NSObject new];

        } else {
            NSAssert( t.kmlDirPath, @"The given Trail's kmlDirPath is nil." );
            self = nil;
        }
    }
    return  self;
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
            initWithDirPath:self.trail.kmlDirPath
        ];
        __trackLocations = parser.locations;
    }
    return __trackLocations;
}


- (CLLocationDistance) trackLength {
    if ( __trackLength < 0.0  &&  self.trackLocations ) {
        CLLocation* lastLoc = [self.trackLocations objectAtIndex:0];
        for ( CLLocation* loc in self.trackLocations ) {
            __trackLength += [loc distanceFromLocation:lastLoc];
        }
    }
    return  __trackLength;
}


- (CLLocation*) trackInterpolate:(double)portionOfLength {
    CLLocation* interpLoc = nil;

    if ( 0.0 <= portionOfLength  &&  portionOfLength <= 1.0 ) {
        CLLocationDistance toGo = portionOfLength * self.trackLength;
        CLLocation* lastLoc = [self.trackLocations objectAtIndex:0];

        for ( CLLocation* loc in self.trackLocations ) {
            CLLocationDistance distFromLast = [loc distanceFromLocation:lastLoc];
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

    return  interpLoc;
}


#pragma mark - Implementation of Protocol MKOverlay


- (CLLocationCoordinate2D) coordinate {
    [self checkTrailMapDimensions];
    return  self.trail.mapCoordinate;
}


- (MKMapRect) boundingMapRect {
    [self checkTrailMapDimensions];
    return  self.trail.boundingMapRect;
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
    [self checkTrailMapDimensions];
    return  (
        self.trail.hasMapDimensions  &&
        MKMapRectIntersectsRect( self.trail.boundingMapRect, mapRect )
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


/** Ensures that self.trail has values for field giving the rough dimensions of
    the trail's track on the map. If it does, this method does nothing.
    Otherwise, self.polyline is created, if necessary, and the dimensions are
    assigned to the trail's fields.
*/
- (void) checkTrailMapDimensions {
    if ( ! self.trail.hasMapDimensions  &&  self.polyline ) {
        //  We don't have trail map dimensions in the trail managed object, so
        //  we need to parse the KML file. Obtaining polyline does this.
        self.trail.boundingMapRect = self.polyline.boundingMapRect;

        //  Set the map coordinate. This is where the annotation view will be
        //  displayed. We make it the point midway along the track.
        self.trail.mapCoordinate = [self trackInterpolate:0.5].coordinate;
    }
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
