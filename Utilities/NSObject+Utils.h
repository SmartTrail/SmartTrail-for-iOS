//
//  NSObject+Utils.h
//  Places
//
//  Created by Tyler Perkins on 2012-02-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NSObject_Utils)

/** Returns the given object if it is not nil, otherwise returns the receiver.
*/
- (id) unless:(id)obj;

@end
