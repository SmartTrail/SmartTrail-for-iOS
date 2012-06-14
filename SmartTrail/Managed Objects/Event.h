//
//  Event.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic) NSString * descriptionFull;
@property (nonatomic) NSDate * downloadedAt;
@property (nonatomic) NSDate * endAt;
@property (nonatomic) NSString * id;
@property (nonatomic) NSString * name;
@property (nonatomic) NSDate * startAt;
@property (nonatomic) NSDate * updatedAt;
@property (nonatomic) NSString * url;

@end
