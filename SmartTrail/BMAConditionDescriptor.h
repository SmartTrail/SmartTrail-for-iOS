//
//  BMAConditionDescriptor.h
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMAConditionDescriptor : NSObject

@property (nonatomic, assign) NSUInteger area;
@property (nonatomic, copy)   NSString   *comment;
@property (nonatomic, copy)   NSString   *condition;
@property (nonatomic, assign) NSUInteger conditionId;
@property (nonatomic, assign) NSUInteger commentId;
@property (nonatomic, copy)   NSString   *nickName;
@property (nonatomic, assign) NSUInteger trailId;
@property (nonatomic, copy)   NSDate     *lastUpdated;
@property (nonatomic, assign) NSUInteger userId;

- (void) dealloc;
- (NSString*) description;

@end
