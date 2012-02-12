//
//  BMATrailDescriptor.h
//  SmartTrail
//
//  Created by John Dumais on 2/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMATrailDescriptor : NSObject

@property(nonatomic, assign) NSUInteger aerobicRating;
@property(nonatomic, assign) NSUInteger area;
@property(nonatomic, assign) NSUInteger condition;
@property(nonatomic, assign) NSUInteger coolRating;
@property(nonatomic, copy)   NSString   *description;
@property(nonatomic, copy)   NSString   *fullDescription;
@property(nonatomic, assign) NSUInteger elevationGain;
@property(nonatomic, assign) NSUInteger trailId;
@property(nonatomic, assign) Float32    length;
@property(nonatomic, copy)   NSString   *name;
@property(nonatomic, assign) NSUInteger techRating;
@property(nonatomic, copy)   NSDate     *lastUpdated;
@property(nonatomic, copy)   NSString   *url;

- (void) dealloc;
- (NSString*) description;

@end
