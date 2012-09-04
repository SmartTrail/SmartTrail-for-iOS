//
// Created by tyler on 2012-08-22.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "Trail.h"
#import <MapKit/MapKit.h>


/** This category adds the ability to store and recall a map coordinate of a
    point on this trail's polyline and the polyline's bounding rectangle.
*/
@interface Trail (Mapping)


/** Returns YES iff this trail has map data. The implementation actually just
    checks that boundingMapRect has positive width and height.
*/
@property (readonly,nonatomic) BOOL                   hasMapDimensions;


@property (nonatomic)          CLLocationCoordinate2D mapCoordinate;


@property (nonatomic)          MKMapRect              boundingMapRect;


@end
