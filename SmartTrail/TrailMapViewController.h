//
// Created by tyler on 2012-07-20.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Trail.h"


/** This class encapsulates the display of and interaction with the map of a
    particular trail.
*/
@interface TrailMapViewController : UIViewController<MKMapViewDelegate>


/** The map view which will be shown when the user taps the super-view's "Map"
    segmented control.
*/
@property (nonatomic)        IBOutlet MKMapView*   mapView;


/** The trail being examined. Must be set by the TrailDetailViewController
 BEFORE the table of conditions is displayed.
 */
@property (strong,nonatomic)          Trail*       trail;


@end
