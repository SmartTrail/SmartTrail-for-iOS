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

@property (nonatomic, retain) NSString * descriptionFull;
@property (nonatomic, retain) NSDate * downloadedAt;
@property (nonatomic, retain) NSDate * endAt;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSString * url;

@end
