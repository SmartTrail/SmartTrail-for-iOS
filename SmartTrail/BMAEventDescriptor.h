//
//  BMAEventDescriptor.h
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMAEventDescriptor : NSObject

@property (nonatomic, assign) NSUInteger eventId;
@property (nonatomic, copy)   NSString   *name;
@property (nonatomic, copy)   NSString   *eventDescription;
@property (nonatomic, copy)   NSDate     *lastUpdated;
@property (nonatomic, copy)   NSString   *url;

- (void) dealloc;
- (NSString*) description;

@end
