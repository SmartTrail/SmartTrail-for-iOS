//
//  Area.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-02.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trail;

@interface Area : NSManagedObject

@property (nonatomic) NSDate * downloadedAt;
@property (nonatomic) NSString * id;
@property (nonatomic) NSString * name;
@property (nonatomic) NSSet *trails;
@end

@interface Area (CoreDataGeneratedAccessors)

- (void)addTrailsObject:(Trail *)value;
- (void)removeTrailsObject:(Trail *)value;
- (void)addTrails:(NSSet *)values;
- (void)removeTrails:(NSSet *)values;

@end
