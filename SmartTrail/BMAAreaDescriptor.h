//
//  BMAAreaDescriptor.h
//  SmartTrail
//
//  Created by John Dumais on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMAAreaDescriptor : NSObject

@property(nonatomic, assign) NSUInteger id;
@property(nonatomic, retain) NSString *areaName;

- (void) dealloc;

@end
