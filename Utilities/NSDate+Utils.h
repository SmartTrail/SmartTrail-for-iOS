//
//  NSDate+Utils.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (NSDate_Utils)


/** Parses the given string using the given format into the number of seconds
    from the reference date, 1 January 1970, GMT. The format must be of the form
    specified for C function strftime (see "man strftime"). An assertion
    indicating a parsing failure will be triggered if we're running in DEBUG
    mode. Otherwise [self badTimeInterval] is returned (see below).

    For example, sending @"Wed, 07 Mar 2012 15:50:44 GMT" with format
    @"%a, %d %b %Y %T %Z" results in the NSTimeInterval 1331135444.0.
*/
+ (NSTimeInterval)
    timeIntervalSince1970FromString:(NSString*)str
                           inFormat:(NSString*)fmt;


/** Creates and returns an NSDate object set to the value parsed from the given
    string, using the given format. (See "man strftime"). An assertion
    indicating a parsing failure will be triggered if we're running in DEBUG
    mode. Otherwise, nil is returned on failure.
*/
+ (id) dateFromString:(NSString*)str inFormat:(NSString*)fmt;


/** Returns an NSDate object set to the value parsed from the given string,
    using the given format. (See "man strftime"). An assertion
    indicating a parsing failure will be triggered if we're running in DEBUG
    mode. Otherwise, nil is returned on failure.
*/
- (id) initFromString:(NSString*)str inFormat:(NSString*)fmt;


/** Returns a large negative value representing an erroneous result. Note that
    this implementation assumes that NSDate's distantPast class method is a
    constant, which is not documented but undoubtedly true.
*/
+ (NSTimeInterval) badTimeInterval;


- (BOOL) isBefore:(NSDate*)aDate;


- (BOOL) isAfter:(NSDate*)aDate;


@end
