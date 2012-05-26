//
//  NSDate+Utils.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Utils.h"


@implementation NSDate (NSDate_Utils)


+ (NSTimeInterval)
    timeIntervalSince1970FromString:(NSString*)str
                           inFormat:(NSString*)fmt
{
    const char* cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    const char* cFmt = [fmt cStringUsingEncoding:NSASCIIStringEncoding];
    time_t secsSince1970 = -1L;

    if ( cStr && cFmt ) {
        //  Parse the text into a tm structure.
        struct tm tStruct;
        strptime( cStr, cFmt, &tStruct );

        secsSince1970 = mktime(&tStruct);
    }

    NSAssert(
        secsSince1970 != -1L,
        @"Could not parse date/time string \"%@\" from format \"%@\".",
        str,
        fmt
    );

    return  secsSince1970 == -1
    ?   [self badTimeInterval]
    :   (NSTimeInterval)secsSince1970;
}


+ (id) dateFromString:(NSString*)str inFormat:(NSString*)fmt {
    NSTimeInterval interval = [self
        timeIntervalSince1970FromString:str inFormat:fmt
    ];
    return  interval == [self badTimeInterval]
    ?   nil
    :   [self dateWithTimeIntervalSince1970:interval];
}


+ (NSTimeInterval) badTimeInterval {
    return  [[NSDate distantPast] timeIntervalSince1970];
}


- (id) initFromString:(NSString*)str inFormat:(NSString*)fmt {
    NSTimeInterval interval = [NSDate
        timeIntervalSince1970FromString:str inFormat:fmt
    ];
    return  interval == [NSDate badTimeInterval]
    ?   nil
    :   [self initWithTimeIntervalSince1970:interval];
}


- (BOOL) isBefore:(NSDate*)aDate {
    return  [self compare:aDate] == NSOrderedAscending;
}


- (BOOL) isAfter:(NSDate*)aDate {
    return  [self compare:aDate] == NSOrderedDescending;
}


@end
