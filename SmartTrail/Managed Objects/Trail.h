//
//  Trail.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-08-23.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Area, Condition;

@interface Trail : NSManagedObject

@property (nonatomic, retain) NSNumber * aerobicRating;
@property (nonatomic, retain) NSNumber * coolRating;
@property (nonatomic, retain) NSString * descriptionFull;
@property (nonatomic, retain) NSString * descriptionPartial;
@property (nonatomic, retain) NSDate * downloadedAt;
@property (nonatomic, retain) NSNumber * elevationGain;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * isFavorite;
@property (nonatomic, retain) NSString * kmlDirPath;
@property (nonatomic, retain) NSString * kmzURL;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * techRating;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * mapCoordLat;
@property (nonatomic, retain) NSNumber * mapCoordLon;
@property (nonatomic, retain) NSNumber * mapRectX;
@property (nonatomic, retain) NSNumber * mapRectY;
@property (nonatomic, retain) NSNumber * mapRectWidth;
@property (nonatomic, retain) NSNumber * mapRectHeight;
@property (nonatomic, retain) Area *area;
@property (nonatomic, retain) NSSet *conditions;
@end

@interface Trail (CoreDataGeneratedAccessors)

- (void)addConditionsObject:(Condition *)value;
- (void)removeConditionsObject:(Condition *)value;
- (void)addConditions:(NSSet *)values;
- (void)removeConditions:(NSSet *)values;

@end
