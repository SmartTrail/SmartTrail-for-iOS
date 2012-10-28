//
//  MapsViewController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-10-11.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MapsViewController : UIViewController<MKMapViewDelegate>


@property (nonatomic)        IBOutlet MKMapView*   mapView;


@end
