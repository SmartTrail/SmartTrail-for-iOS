//
//  BMAAreaDescriptor.m
//  SmartTrail
//
//  Created by John Dumais on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAAreaDescriptor.h"

@implementation BMAAreaDescriptor

@synthesize areaName;
@synthesize id;

- (void) dealloc
{
    [areaName release];
    [super dealloc];
}

@end
