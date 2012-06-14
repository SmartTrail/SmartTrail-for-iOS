//
//  Trail.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-04.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Area, Condition;

@interface Trail : NSManagedObject

@property (nonatomic) NSNumber * aerobicRating;
@property (nonatomic) NSNumber * coolRating;
@property (nonatomic) NSString * descriptionFull;
@property (nonatomic) NSString * descriptionPartial;
@property (nonatomic) NSDate * downloadedAt;
@property (nonatomic) NSNumber * elevationGain;
@property (nonatomic) NSString * id;
@property (nonatomic) NSNumber * isFavorite;
@property (nonatomic) NSNumber * length;
@property (nonatomic) NSString * name;
@property (nonatomic) NSNumber * techRating;
@property (nonatomic) NSDate * updatedAt;
@property (nonatomic) NSString * url;
@property (nonatomic) Area *area;
@property (nonatomic) NSSet *conditions;
@end

@interface Trail (CoreDataGeneratedAccessors)

- (void)addConditionsObject:(Condition *)value;
- (void)removeConditionsObject:(Condition *)value;
- (void)addConditions:(NSSet *)values;
- (void)removeConditions:(NSSet *)values;

@end
