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

@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSDate * downloadedAt;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Trail *trail;

@end
