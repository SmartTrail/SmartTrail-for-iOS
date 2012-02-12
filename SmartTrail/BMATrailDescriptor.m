//
//  BMATrailDescriptor.m
//  SmartTrail
//
//  Created by John Dumais on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMATrailDescriptor.h"

@implementation BMATrailDescriptor

@synthesize aerobicRating;
@synthesize area;
@synthesize condition;
@synthesize coolRating;
@synthesize description;
@synthesize fullDescription;
@synthesize elevationGain;
@synthesize trailId;
@synthesize length;
@synthesize name;
@synthesize techRating;
@synthesize lastUpdated;
@synthesize url;

- (void) dealloc
{
    [description release];
    [fullDescription release];
    [name release];
    [lastUpdated release];
    [url release];
    
    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:
     @"Aerobic rating: %d\n"
     "Area: %d\n"
     "Condition: %d\n"
     "Cool rating: %d\n"
     "Description: %@\n"
     "Full description: %@\n"
     "Elevation gain: %d\n"
     "Trail id: %d\n"
     "Length: %f\n"
     "Name: %@\n"
     "Tech rating: %d\n"
     "Last updated: %@\n"
     "Url: %@\n",
     aerobicRating, area, condition, coolRating, description, fullDescription, elevationGain,
     trailId, length, name, techRating, lastUpdated, url];
}

@end
