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


- (NSDate*) date {
    //  Get the text of the time of the response from the Date header, which
    //  looks like "Wed, 07 Mar 2012 15:50:44 GMT".
    NSString* nowStr = [[self allHeaderFields] objectForKey:@"Date"];

    return  [NSDate dateFromString:nowStr inFormat:DateHeaderFormat];
}


@end
