//
// Created by tyler on 2012-07-18.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <UIKit/UIKit.h>
#import "LinkingWebViewDelegate.h"
#import "Trail.h"


/** This class encapsulates the display of basic information about the trail
    being viewed.
*/
@interface TrailInfoViewController : UIViewController


/** Widgets displaying info about the trail.
*/
@property (nonatomic)        IBOutlet UILabel*     statsLabel;
@property (nonatomic)        IBOutlet UIImageView* techRatingImageView;
@property (nonatomic)        IBOutlet UIImageView* aerobicRatingImageView;
@property (nonatomic)        IBOutlet UIImageView* coolRatingImageView;
@property (nonatomic)        IBOutlet UIWebView*   descriptionWebView;


/** The descriptionWebView's delegate, which listens for when the user taps
    a trail link. We don't actually use it in this class, but somebody must
    have a strong reference to it, so it won't be released.
*/
@property (strong,nonatomic) IBOutlet LinkingWebViewDelegate*
                                                   linkingWebViewDelegate;


/** The trail being examined. Must be set by the TrailDetailViewController
    BEFORE the table of conditions is displayed.
*/
@property (strong,nonatomic)          Trail*       trail;


@end
