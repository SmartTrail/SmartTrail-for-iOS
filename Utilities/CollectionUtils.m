//
//  CollectionUtils.m
//
//
//  Created by Tyler Perkins on 2011-10-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CollectionUtils.h"

#define BUFF_SIZE 16

NSMutableArray* mutableArrayFor( id<NSFastEnumeration> xs );


id reduce( id (^f)(id accum, id x), id x0, id<NSFastEnumeration> xs ) {
    id result = x0;
    for ( id x in xs ) {
        result = f( result, x );
    }
    return result;
}


NSMutableArray* filter( BOOL (^pred)(id), id<NSFastEnumeration> xs ) {
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


NSMutableArray* map( id (^f)(id), id<NSFastEnumeration> xs ) {
    NSMutableArray* arr = mutableArrayFor(xs);
    __block BOOL yOK = YES;
    return reduce(
        ^(id accum, id x){
            if ( yOK ) {
                id y = f(x);
                yOK =  y != nil;
                if ( yOK )  [accum addObject:y];
            }
            return accum;
        },
        arr,
        xs
    );
}


NSMutableArray* map2(
    id (^f)(id,id), id<NSFastEnumeration> xs1, id<NSFastEnumeration> xs2
) {
    NSFastEnumerationState  state1,             state2;
    __unsafe_unretained id  buff1[BUFF_SIZE],   buff2[BUFF_SIZE];
    NSUInteger              itemsCount1,        itemsCount2;
    NSUInteger              itemsRemaining1,    itemsRemaining2;

    state1.state    = state2.state    = 0;
    itemsRemaining1 = itemsRemaining2 = 0;
    NSMutableArray* result = mutableArrayFor(xs1);

    //
    //  Some notes about fast enumeration:
    //
    //  Here we employ the NSFastEnumeration method,
    //  countByEnumeratingWithState:objects:count:. The NSFastEnumerationState
    //  argument is a structure handed to the collection for its own use to
    //  remember the state of the iteration from the previous call. It is
    //  conventional to pass in 0 as the value of the NSFastEnumerationState's
    //  state field, but no other information is provided by the sender. It does
    //  provide output, however, the items the caller needs for iterating over.
    //  On return, the NSFastEnumerationState's itemsPtr points to the first
    //  item in a (C array) batch of of addresses. The integer returned by the
    //  method is just the number of items in the batch. If this integer is
    //  not zero, the caller can then read that many items, starting at
    //  itemsPtr. The actual storage for the items may be maintained internally
    //  by the collection, or the given buffer of the given size may be employed
    //  by the receiver. Again, this storage is used only be the collections
    //  implementation of the method and has no effect on the caller, except
    //  that the caller must provide the space, and itemsPtr might point into
    //  it.
    //
    //  Below, we repeatedly fetch batches of items from xs1 and/or xs2, keeping
    //  track of how many of each remain to be iterated over. When and only when
    //  we have none remaining from one of the batches do we call the method
    //  on the respective collection to get the next batch. Note that the
    //  collections could return different batch sizes.
    //
    //  When one of the collections is exhasted, its
    //  countByEnumeratingWithState:objects:count: returns 0, causing the loop
    //  to fall through. The accumulated result is then returned.
    //
    while (
        (itemsRemaining1 || (
            //  None from previous batch remaining. Fetch from xs1 again.
            //  If 0 returned, fall out of loop, we're done.
            itemsRemaining1 = itemsCount1 = [xs1
                countByEnumeratingWithState:&state1 objects:buff1 count:BUFF_SIZE
            ]
        ))
        &&
        (itemsRemaining2 || (
            //  None from previous batch remaining. Fetch from xs2 again.
            //  If 0 returned, fall out of loop, we're done.
            itemsRemaining2 = itemsCount2 = [xs2
                countByEnumeratingWithState:&state2 objects:buff2 count:BUFF_SIZE
            ]
        ))
    ) {
        //  Iterate over the two batches:
        //
        //  There are items remaining to process from BOTH xs1 and xs2. Iterate
        //  below min( itemsRemaining1, itemsRemaining2 ) times. When looping
        //  below finishes, at least one of itemsRemaining1 and itemsRemaining2
        //  will be zero. Any that are will be updated above and the respective
        //  itemsPtr fields will be updated. And once again, if both are non-
        //  zero, we'll be back here again.
        //
        do {
            NSUInteger i1 = itemsCount1 - itemsRemaining1--;
            NSUInteger i2 = itemsCount2 - itemsRemaining2--;

            [result
                addObject:f( *(state1.itemsPtr + i1), *(state2.itemsPtr + i2) )
            ];

        } while ( itemsRemaining1 && itemsRemaining2 );
    }

    return  result;
}


#pragma mark - Private functions


/** Creates a new autoreleased NSMutableArray appropriate for use with the
    given collection, xs. If xs responds to the count method, returns an array
    with capacity [xs count]. Otherwise, returns an array with capacity 16.
*/
NSMutableArray* mutableArrayFor( id<NSFastEnumeration> xs ) {
    //  Guess at the size we'll need for the returned array.
    NSUInteger size =  [(id)xs respondsToSelector:@selector(count)]
                       ?   [(id)xs count]   // Almost always this.
                       :   BUFF_SIZE;       // Almost never this!
    return  [NSMutableArray arrayWithCapacity:size];
}


@implementation NSArray (CollectionUtils)


- (void) each:(void(^)(id))toDo {
    [self enumerateObjectsUsingBlock:^( id obj, NSUInteger idx, BOOL* stop ){
        toDo(obj);
    }];
}


@end
