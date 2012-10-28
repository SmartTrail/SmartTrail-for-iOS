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


/** Checks to see that directory self.trail.kmlDir exists, downloading and
    decompressing a KMZ file to create it if necessary. If so, then parses the
    KML data as necessary to create a MKOverlay (and hence also MKAnnotation)
    implementation for self.mapView to display. Returns YES iff all this was
    successful and there is KML data to display.
*/
- (void) parseKMLDataIfOkDo:(void (^)())blk;


@end
