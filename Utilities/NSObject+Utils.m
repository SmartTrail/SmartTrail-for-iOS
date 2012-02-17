//
//  NSObject+Utils.m
//  Places
//
//  Created by Tyler Perkins on 2012-02-08.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NSObject+Utils.h"

@implementation NSObject (NSObject_Utils)

- (id) unless:(id)obj {
    return  obj ? obj : self;
}

@end
