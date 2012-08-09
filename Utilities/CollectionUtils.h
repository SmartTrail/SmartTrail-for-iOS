//
//  CollectionUtils.h
//
//
//  Created by Tyler Perkins on 2011-10-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


/** This function performs a left fold on the given collection. It applies the
    given 2-arg. function, f, to the last result and the next element in the
    collection. Initially, the "last result" is x0. The result of applying f
    the final time is returned when the last element of the collection has been
    applied. Thus, all elements of the collection are visited.
*/
id reduce( id (^f)(id accum, id x), id x0, id<NSFastEnumeration> xs );


/** Standard filter and map functions. All elements of the given collection are
    visited.
*/
NSMutableArray* filter( BOOL (^pred)(id), id<NSFastEnumeration> xs );
NSMutableArray* map( id (^f)(id), id<NSFastEnumeration> xs );


/** Works like map(f,xs), above, but here the function, f, takes two arguments.
    The first element of the returned array is the result of applying f to to
    the first element of xs1 and the first element of xs2. The second returned
    element is the result of f applied to the second element of xs1 and the
    second element of xs2, and so on. The calculation stops when one of the
    given arrays is exhausted. Thus, [resultArray count] ==
    min( [xs1 count], [xs2 count] ).
*/
NSMutableArray* map2(
    id (^f)(id,id), id<NSFastEnumeration> xs1, id<NSFastEnumeration> xs2
);


@interface NSArray (CollectionUtils)


/** An abbreviated form of NSArray's enumerateObjectsUsingBlock: method.
    Returns void, so is used only for side effects.
*/
- (void) each:(void(^)(id))f;


@end
