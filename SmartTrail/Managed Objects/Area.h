//
//  Area.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Trail;

@interface Area : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *trails;
@end

@interface Area (CoreDataGeneratedAccessors)

- (void)addTrailsObject:(Trail *)value;
- (void)removeTrailsObject:(Trail *)value;
- (void)addTrails:(NSSet *)values;
- (void)removeTrails:(NSSet *)values;

@end
