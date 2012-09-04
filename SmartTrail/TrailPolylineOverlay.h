//
// Created by tyler on 2012-08-21.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Trail.h"


/** As with other MKOverlay subclasses, an instance is provided to an MKMapView
    to describe the coordinate and boundingMapRect surrounding a shape to be
    drawn. The actual shape or the view to draw it may not be needed at the
    time of instantiation. For example, if the map view will display the
    location of dozens of trails, but not their shapes, it only needs the
    coordinate for each trail, which could be stored in the trail managed
    object. Later when the user zooms in, the shape must be parsed and
    provided to the map view as a MKPolyline object does.

    So this class ACTS like MKPolyline. But the full parsed sequence of points
    along the trail is required to instantiate an MKPolyline object, even if
    only its coordinate and boundingMapRect methods are called by the map view.
    The coordinate and boundingMapRect values may be saved in the trail managed
    object, so this class provides that data when needed, but actually does
    parsing only when necessary. When other MKPolyline methods are called, an
    actual MKPolyline object is instantiated and calls are passed to it.
*/
@interface TrailPolylineOverlay : NSProxy<MKOverlay>


/** The trail provided to the initializer.
*/
@property (readonly,strong,nonatomic) Trail*             trail;


/** An array of CLLocation objects generated from the KML data.
*/
@property (readonly,strong,nonatomic) NSMutableArray*    trackLocations;


/** The sum of the great-circle distance in meters between each successive
    location parsed from the KML. Altitude of the locations is not considered.
*/
@property (readonly,nonatomic)        CLLocationDistance trackLength;


- (id) initWithTrail:(Trail*)t;


/** Returns a point along the trail at a portion of its length, where a given
    portion of 0.0 yields the start of the trail, and a portion of 1.0 yields
    its end location. The returned location may lie between two successive track
    locations of the trail. Distance is by great-circle, so altitude is not
    figured in.
*/
- (CLLocation*) trackInterpolate:(double)portionOfLength;


@end
