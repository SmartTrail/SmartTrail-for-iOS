//
//  Trail.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-20.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Area;

@interface Trail : NSManagedObject

@property (nonatomic, retain) NSNumber * aerobicRating;
@property (nonatomic, retain) NSNumber * condition;
@property (nonatomic, retain) NSNumber * coolRating;
@property (nonatomic, retain) NSString * descriptionFull;
@property (nonatomic, retain) NSString * descriptionPartial;
@property (nonatomic, retain) NSNumber * elevationGain;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * techRating;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Area *area;

@end
