//
//  NSHTTPURLResponse+Utils.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSHTTPURLResponse+Utils.h"
#import "NSDate+Utils.h"
#import <time.h>

static NSString* DateHeaderFormat = @"%a, %d %b %Y %T %Z";


@implementation NSHTTPURLResponse (NSHTTPURLResponse_Utils)


#pragma mark - Private methods and functions


- (NSDate*) dateForHeader:(NSString*)headerStr {
    //  Get the text of the time in the indicated response header, which
    //  looks like "Wed, 07 Mar 2012 15:50:44 GMT".
    NSString* dateStr = [[self allHeaderFields] objectForKey:headerStr];

    return  [NSDate dateFromString:dateStr inFormat:DateHeaderFormat];
}


#pragma mark - Methods for easy access to date fields


- (NSDate*) date {
    return  [self dateForHeader:@"Date"];
}


- (NSDate*) lastModifiedDate {
    return  [self dateForHeader:@"Last-Modified"];
}


- (NSDate*) expiresDate {
    return  [self dateForHeader:@"Expires"];
}


@end
