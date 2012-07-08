//
//  NSHTTPURLResponse+Utils.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (NSHTTPURLResponse_Utils)


/** Returns an NSDate parsed from the text in the Date header of the receiver.
    It is assumed this text is in strftime-format, @"%a, %d %b %Y %T %Z". This
    is supposed to represent the date and time, according to the server, that
    the response was sent.
*/
- (NSDate*) date;


/** Returns an NSDate parsed from the text in the Last-Modified header of the
    receiver. It is assumed this text is in strftime-format,
    @"%a, %d %b %Y %T %Z".
*/
- (NSDate*) lastModifiedDate;


/** Returns an NSDate parsed from the text in the Expires header of the
    receiver. It is assumed this text is in strftime-format,
    @"%a, %d %b %Y %T %Z".
*/
- (NSDate*) expiresDate;


@end
