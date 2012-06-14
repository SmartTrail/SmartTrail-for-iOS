//
//  CollectionUtils.m
//
//
//  Created by Tyler Perkins on 2011-10-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CollectionUtils.h"

NSMutableArray* mutableArrayFor( NSObject<NSFastEnumeration>* xs );


id reduce( id (^f)(id,id), id x0, NSObject<NSFastEnumeration>* xs ) {
    id result = x0;
    for ( id x in xs ) {
        result = f( result, x );
    }
    return result;
}


NSMutableArray* filter( BOOL (^pred)(id), NSObject<NSFastEnumeration>* xs ) {
    NSMutableArray* arr = mutableArrayFor(xs);
    return reduce(
        ^(id accum, id x){
            if ( pred(x) ) [accum addObject:x];
            return accum;
        },
        arr,
        xs
    );
}


NSMutableArray* map( id (^f)(id), NSObject<NSFastEnumeration>* xs ) {
    NSMutableArray* arr = mutableArrayFor(xs);
    return reduce(
        ^(id accum, id x){
            [accum addObject:f(x)];
            return accum;
        },
        arr,
        xs
    );
}


#pragma mark - Private functions


/** Creates a new autoreleased NSMutableArray appropriate for use with the
    given collection, xs. If xs responds to the count method, returns an array
    with capacity [xs count]. Otherwise, returns an array with capacity 16.
*/
NSMutableArray* mutableArrayFor( NSObject<NSFastEnumeration>* xs ) {
    //  Guess at the size we'll need for the returned array.
    NSUInteger size =  [xs respondsToSelector:@selector(count)]
                       ?   [(id)xs count]   // Almost always this.
                       :   16;              // Almost never this!
    return  [NSMutableArray arrayWithCapacity:size];
}


@implementation NSArray (CollectionUtils)
@end
