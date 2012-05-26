//
// Created by tyler on 2012-05-26.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


/** This class is used to track the difference between the number of times some
    network activity ended and the number of times one ended. If that difference
    becomes positive, the network activity indicator in the upper left corner of
    the screen is made visible. It looks like a little, spinning pinwheel. If
    the difference becomes non-positive, then it is hidden.
*/
@interface NetActivityIndicatorController : NSObject


/** Sent to indicate that a network activity began. Tracks the number of such
    activities and displays the Network Activity Indicator if any activities
    have started and not ended yet. A call to this method must be followed
    at some point by a call to aNetActivityDidStop when the activity ends.
*/
- (void) aNetActivityDidStart;


/** Sent to indicate that a network activity ended. Tracks the number of such
    activities and hides the Network Activity Indicator if all activities
    have ended. A call to this method must eventually follow the call to
    aNetActivityDidStart made when the activity began.
*/
- (void) aNetActivityDidStop;


@end
