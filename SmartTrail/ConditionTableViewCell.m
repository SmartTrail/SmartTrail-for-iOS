//
//  ConditionTableViewCell.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-09.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ConditionTableViewCell.h"
#import "AppDelegate.h"
#import "NSString+Utils.h"

static NSDateFormatter* ConditionDateFormatter;


@implementation ConditionTableViewCell


@synthesize updatedAtLabel = __updatedAtLabel;
@synthesize authorLabel = __authorLabel;
@synthesize commentLabel = __commentLabel;
@synthesize ratingImageView = __ratingImageView;




+ (void) initialize {
    ConditionDateFormatter = [NSDateFormatter new];
    //  Set the format using short day of week, month abbreviation, and day
    //  of month. The actual format string depends on the current local.
    [ConditionDateFormatter setDateFormat:[NSDateFormatter
        dateFormatFromTemplate:@"EdMMM"
                       options:0
                        locale:[NSLocale currentLocale]
    ]];
}


/** Called by the FetchedResultsTableDataSource when this cell needs to be
    populated with data from a managed object. This is needed because this cell
    is custom, so does not make use of textLabel or detailTextLabel.
*/
- (void) willShowManagedObject:(Condition*)condition {
    self.updatedAtLabel.text = [ConditionDateFormatter
        stringFromDate:condition.updatedAt
    ];
    self.authorLabel.text = condition.authorName;
    self.commentLabel.text = [condition.comment trim];
    self.ratingImageView.image = [APP_DELEGATE
        imageForRating:[condition.rating integerValue] inRange:0 through:4
    ];
}


@end
