//
//  NSString+Utils.m
//  Places
//
//  Created by Tyler Perkins on 2011-06-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Utils.h"


@implementation NSString (NSString_Utils)


- (BOOL) isNotBlank {
    return  0 != [
        [self stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]
        ]
        length
    ];
}


- (NSString*) trim {
    return  [self
        stringByTrimmingCharactersInSet:[NSCharacterSet
            whitespaceAndNewlineCharacterSet
    ]];
}


@end
