//
//  BMAConditionDescriptor.m
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAConditionDescriptor.h"

@implementation BMAConditionDescriptor

@synthesize area;
@synthesize comment;
@synthesize condition;
@synthesize conditionId;
@synthesize commentId;
@synthesize nickName;
@synthesize trailId;
@synthesize lastUpdated;
@synthesize userId;

- (void) dealloc
{
    [comment release];
    [condition release];
    [nickName release];
    [lastUpdated release];
    [super dealloc];
}

- (NSString*) description
{
    return [NSString stringWithFormat:
     @"Area: %d\n"
     "Comment: %@\n"
     "Condition: %@\n"
     "Condition id: %d\n"
     "Comment id: %d\n"
     "Nickname: %@\n"
     "Trail id: %d\n"
     "Last updated: %@\n"
     "User id: %d\n",
     [self area], [self comment], [self condition], [self conditionId], [self commentId], [self nickName],
            [self trailId], [self lastUpdated], [self userId]];
}

@end
