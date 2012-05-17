//
//  NSString+Utils.m
//  Places
//
//  Created by Tyler Perkins on 2011-06-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
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


- (NSString*) decapitalizedString {
    NSMutableString* mStr = [[self mutableCopy] autorelease];
    NSRange entireRng;
    entireRng.location = 0;
    entireRng.length = [mStr length];
    [mStr
        enumerateSubstringsInRange:entireRng
                           options:NSStringEnumerationByWords
                        usingBlock:
            ^(NSString* word, NSRange wordRng, NSRange enclosingRng, BOOL* stop) {

                NSRange char1Rng = wordRng;
                char1Rng.length = 1;

                NSString* lowerLetter = [[mStr substringWithRange:char1Rng]
                    lowercaseString
                ];

                [mStr replaceCharactersInRange:char1Rng withString:lowerLetter];
            }
    ];
    return  mStr;
}


@end
