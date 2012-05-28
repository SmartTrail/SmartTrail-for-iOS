//
// Created by tyler on 2012-05-26.
//


#import <Foundation/Foundation.h>


/** This class is used to control the network activity indicator in the upper
    left corner of the screen (which looks like a spinning pinwheel). It works
    by tracking the difference between the number of times some network activity
    started versus the number of times one stopped. If there have been more
    starts than stops, the indicator is made visible (or stays visible, if it
    was already visible). Otherwise, it becomes (or stays) hidden.

    Use this class only by calling its class methods. It makes use of the fact
    that a class is a singleton. It must be a singleton because it must have
    exclusive access to singleton UIApplication's
    networkActivityIndicatorVisible property. Thus, attempting to instantiate
    this class will fail an assertion. Also, do not directly manipulate the
    networkActivityIndicatorVisible property. Just use this class' methods.
*/
@interface NetActivityIndicatorController : NSObject


/** Sent to indicate that a network activity began. Tracks the number of such
    activities and displays the Network Activity Indicator if any activities
    have started and not ended yet. A call to this method must be followed
    at some point by a call to aNetActivityDidStop when the activity ends.
*/
+ (void) aNetActivityDidStart;


/** Sent to indicate that a network activity ended. Tracks the number of such
    activities and hides the Network Activity Indicator if all activities
    have ended. A call to this method must eventually follow the call to
    aNetActivityDidStart made when the activity began.
*/
+ (void) aNetActivityDidStop;


@end
