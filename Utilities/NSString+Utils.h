//
//  NSString+Utils.h
//  Places
//
//  Created by Tyler Perkins on 2011-06-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSString_Utils)

/** If the receiver is empty, or consists entirely of whitespace, then YES
    is returned. Otherwise, NO is returned. As with any method, the isNotBlank
    message sent to nil results in nil, which is logically equivalent to NO.
    Thus, [str isNotBlank] makes sense even when str is nil.
*/
- (BOOL) isNotBlank;

/** Returns a copy of the receiver with all white space (including newlines)
    removed from both the beginnning and the end.
*/
- (NSString*) trim;

/** Similar to NSString's capitalizedString method, but returns a string with
    the first character from each word in the receiver changed to its
    corresponding lowercase value.
*/
- (NSString*) decapitalizedString;

@end
