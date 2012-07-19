//
// Created by tyler on 2012-07-18.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "TrailInfoController.h"
#import "AppDelegate.h"


@implementation TrailInfoController


@synthesize view = __view;
@synthesize statsLabel = __statsLabel;
@synthesize techRatingImageView = __techRatingImageView;
@synthesize aerobicRatingImageView = __aerobicRatingImageView;
@synthesize coolRatingImageView = __coolRatingImageView;
@synthesize descriptionWebView = __descriptionWebView;
@synthesize linkingWebViewDelegate = __linkingWebViewDelegate;
@synthesize trail = __trail;


- (void) setTrail:(Trail*)trail {
    __trail = trail;

    //  Show trail length and elevation gain if we have data.
    self.statsLabel.text =  self.trail.length.floatValue > 0.0
    ?   [NSString
            stringWithFormat:@"%.1f miles    gain: %d feet",
                self.trail.length.floatValue,
                self.trail.elevationGain.intValue
        ]
    :   @"";

    //  Draw the rating dots.
    self.techRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.techRating.longValue inRange:0 through:10
    ];
    self.aerobicRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.aerobicRating.longValue inRange:0 through:10
    ];
    self.coolRatingImageView.image = [APP_DELEGATE
        imageForRating:self.trail.coolRating.longValue inRange:0 through:10
    ];

    //  Render the description of the trail, which is HTML.
    NSString* bmaBaseUrl = [[NSBundle mainBundle]
        objectForInfoDictionaryKey:@"BmaBaseUrl"
    ];
    [self.descriptionWebView
        loadHTMLString:self.trail.descriptionFull
               baseURL:[NSURL URLWithString:bmaBaseUrl]
    ];
}


@end
