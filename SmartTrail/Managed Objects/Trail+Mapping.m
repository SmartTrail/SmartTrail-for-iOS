//
// Created by tyler on 2012-08-22.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "Trail+Mapping.h"


@implementation Trail (Mapping)


- (BOOL) hasMapDimensions {
    return  (
        self.mapRectWidth.doubleValue  > 0.0  ||
        self.mapRectHeight.doubleValue > 0.0
    );
}


- (CLLocationCoordinate2D) mapCoordinate {
    return  CLLocationCoordinate2DMake(
        self.mapCoordLat.doubleValue, self.mapCoordLon.doubleValue
    );
}


- (void) setMapCoordinate:(CLLocationCoordinate2D)coord {
    self.mapCoordLat = [NSNumber numberWithDouble:coord.latitude ];
    self.mapCoordLon = [NSNumber numberWithDouble:coord.longitude];
}


- (MKMapRect) boundingMapRect {
    return  MKMapRectMake(
        self.mapRectX.doubleValue,
        self.mapRectY.doubleValue,
        self.mapRectWidth.doubleValue,
        self.mapRectHeight.doubleValue
    );
}


- (void) setBoundingMapRect:(MKMapRect)rect {
    self.mapRectX = [NSNumber numberWithDouble:rect.origin.x];
    self.mapRectY = [NSNumber numberWithDouble:rect.origin.y];
    self.mapRectWidth  = [NSNumber numberWithDouble:rect.size.width ];
    self.mapRectHeight = [NSNumber numberWithDouble:rect.size.height];
}


@end
