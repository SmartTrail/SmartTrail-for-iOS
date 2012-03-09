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

    //  Parse the text into a tm structure.
    struct tm tStruct;
    strptime( cStr, cFmt, &tStruct );

    time_t secsSince1970 = mktime(&tStruct);

    NSAssert(
        secsSince1970 != -1L,
        @"Could not parse date/time string \"%@\" from format \"%@\".",
        str,
        fmt
    );

    return (NSTimeInterval)secsSince1970;
}


+ (id) dateFromString:(NSString*)str inFormat:(NSString*)fmt {
    return  [self
        dateWithTimeIntervalSince1970:[self
            timeIntervalSince1970FromString:str
                                   inFormat:fmt
        ]
    ];
}


- (id) initFromString:(NSString*)str inFormat:(NSString*)fmt {
    return  [self
        initWithTimeIntervalSince1970:[NSDate
            timeIntervalSince1970FromString:str
                                   inFormat:fmt
        ]
    ];
}


@end
