//
//  BMAEventDescriptor.m
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAEventDescriptor.h"

@implementation BMAEventDescriptor

@synthesize eventId;
@synthesize name;
@synthesize eventDescription;
@synthesize lastUpdated;
@synthesize url;

- (void) dealloc
{
    [name release];
    [eventDescription release];
    [lastUpdated release];
    [url release];
    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:
     @"Event id: %d\n"
     "Event name: %@\n"       
     "Event description: %@\n"
     "Last updated: %@\n"
     "Url: %@\n",
     [self eventId], [self name], [self eventDescription], [self lastUpdated], [self url]];
}

@end
