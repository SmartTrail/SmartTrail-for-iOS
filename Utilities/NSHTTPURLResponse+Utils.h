//
//  NSHTTPURLResponse+Utils.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-07.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSHTTPURLResponse (NSHTTPURLResponse_Utils)

/** Returns an (autoreleased) NSDate parsed from the text in the Date header
    of the receiver. It is assumed this text is in strftime-format
    @"%a, %d %b %Y %T %Z".
*/
- (NSDate*) date;


@end
