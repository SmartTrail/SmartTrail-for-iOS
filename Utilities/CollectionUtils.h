//
//  CollectionUtils.h
//
//
//  Created by Tyler Perkins on 2011-10-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

id reduce( id (^f)(id,id), id x0, NSObject<NSFastEnumeration>* xs );

NSMutableArray* filter( BOOL (^pred)(id), NSObject<NSFastEnumeration>* xs );
NSMutableArray* map( id (^f)(id), NSObject<NSFastEnumeration>* xs );

@interface NSArray (CollectionUtils)

@end
