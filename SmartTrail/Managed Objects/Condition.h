//
//  Condition.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trail;

@interface Condition : NSManagedObject

@property (nonatomic) NSString * authorName;
@property (nonatomic) NSString * comment;
@property (nonatomic) NSDate * downloadedAt;
@property (nonatomic) NSString * id;
@property (nonatomic) NSNumber * rating;
@property (nonatomic) NSDate * updatedAt;
@property (nonatomic) Trail *trail;

@end
