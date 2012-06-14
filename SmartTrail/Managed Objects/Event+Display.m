//
//  Event+Display.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event+Display.h"
#import "NSDate+Utils.h"

NSString* oneDate( NSDateFormatter* f, NSDate* date );
NSString* twoDates( NSDateFormatter* f, NSDate* start, NSDate* end );
NSString* oneOrTwoDatesWithTimes( NSDateFormatter* f, NSDate* s, NSDate* e );
NSString* oneOrTwoDatesOnly( NSDateFormatter* f, NSDate* s, NSDate* e );
NSString* formatFromTemplate( NSString* template );
BOOL areAlmostEqual( NSDate* earlier, NSDate* later );
BOOL isReasonableHour( NSDate* date );


@implementation Event (Display)


- (NSString*) dateRangeString {
    NSString* str = nil;

    if ( self.endAt  ||  self.startAt ) {
        //  At least one date is provided.

        NSDateFormatter* formatter = [NSDateFormatter new];

        if ( ! self.endAt  ||  ! self.startAt ) {
            //  One of the dates is nil. Use the other.
            str = oneDate( formatter, self.endAt ? self.endAt : self.startAt );

        } else {
            //  Both dates are provided.

            if ( [self.endAt isBefore:self.startAt] ) {
                //  Hmm, something's not quite right, but use start date anyway.
                str = oneDate( formatter, self.startAt );

            } else if ( areAlmostEqual( self.startAt, self.endAt ) ) {
                //  Start and end dates are nearly the same, so just use one.
                str = oneDate( formatter, self.endAt );

            } else {
                //  We have two distinct dates in correct order. Use both.

                str = twoDates( formatter, self.startAt, self.endAt );
            }
        }
    }
    return  str;
}


#pragma mark - Private methods and functions


/** Creates a date string for the given date in an abbreviated format consistent
    with the user's date/time settings. If the time of the date is between 5 AM
    and 11 PM in the current time zone, then also include the time of day.
*/
NSString* oneDate( NSDateFormatter* formatter, NSDate* date ) {

     //  If the hour of day is at a reasonable time (assuming we're in a time
     //  zone close to the event's), show both date and time of day.
    [formatter setDateFormat:formatFromTemplate(
        isReasonableHour( date ) ? @"EdMMMhh:mm" : @"EdMMM"
    )];

    return  [formatter stringFromDate:date];
}


/** Creates a date string consisting of possibly two dates and times. If the
    dates are the same, then the date value is shown using oneDate(), above. If
    both times are "unreasonable", then only the dates are shown. If the dates
    are the same but the times are different, then the date is shown once along
    with both times. Otherwise, both dates and times are shown.
*/
NSString* twoDates( NSDateFormatter* formatter, NSDate* start, NSDate* end ) {
    NSString* str;

    if ( areAlmostEqual(start, end) ) {
        //  The date/times are essentially the same, so just show one.
        str = oneDate( formatter, start );

    } else {
        if ( isReasonableHour( start )  ||  isReasonableHour( end ) ) {
            //  Show both dates or times.
            str = oneOrTwoDatesWithTimes( formatter, start, end );

        } else {
            //  Both hours are unreasonable, so just show the dates.
            str = oneOrTwoDatesOnly( formatter, start, end );
        }
    }
    return str;
}


NSString* oneOrTwoDatesWithTimes(
    NSDateFormatter* formatter, NSDate* start, NSDate* end
) {
    //  First get the dates.
    //
    [formatter setDateFormat:formatFromTemplate(@"EdMMM")];
    NSString* startStr = [formatter stringFromDate:start];
    NSString* endStr   = [formatter stringFromDate:end];

    //  Now get the respective times.
    //
    [formatter setDateFormat:formatFromTemplate(@"hh:mm")];
    NSString* sTimeStr = [formatter stringFromDate:start];
    NSString* eTimeStr = [formatter stringFromDate:end];

    //  Adjust the format if we're on the same day (but at different times).
    //
    return  [startStr isEqual:endStr]
    ?   [NSString stringWithFormat:@"%@, %@ - %@", startStr, sTimeStr, eTimeStr]
    :   [NSString stringWithFormat:@"%@ %@ - %@ %@",
                                   startStr, sTimeStr, endStr, eTimeStr
        ];
}


NSString* oneOrTwoDatesOnly(
    NSDateFormatter* formatter, NSDate* start, NSDate* end
) {
    [formatter setDateFormat:formatFromTemplate(@"EdMMM")];
    NSString* startStr = [formatter stringFromDate:start];
    NSString* endStr   = [formatter stringFromDate:end];

    //  Show both dates, or just one if they are the same.
    return  [startStr isEqual:endStr]
    ?   startStr
    :   [NSString stringWithFormat:@"%@ - %@", startStr, endStr];
}


NSString* formatFromTemplate( NSString* templateString ) {
    return  [NSDateFormatter
        dateFormatFromTemplate:templateString
                       options:0
                        locale:[NSLocale currentLocale]
    ];
}


/** Return YES iff the earlier date follows the time ten minutes prior to the
    later date. No check is made to verify the order of the dates.
*/
BOOL areAlmostEqual( NSDate* earlier, NSDate* later ) {
    return  (
        later.timeIntervalSince1970 - earlier.timeIntervalSince1970 < 600.0
    );
}


BOOL isReasonableHour( NSDate* date ) {
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSInteger hour = [[cal components:NSHourCalendarUnit fromDate:date] hour];
    return  5 <= hour  &&  hour <= 23;
}


@end
