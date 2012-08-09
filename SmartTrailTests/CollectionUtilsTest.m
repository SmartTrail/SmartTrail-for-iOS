//
//  CollectionUtilsTest.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-08-07.
//
//

#import "CollectionUtilsTest.h"
#import "CollectionUtils.h"

@implementation CollectionUtilsTest

{
    NSArray* __emptyArray;
    NSArray* __testArray;
    NSArray* __emptySet;
    NSSet* __testSet;
    NSDictionary* __testDictionary;
}


- (void) setUp {
    __emptyArray = [NSArray arrayWithObjects:nil];
    __testArray = [NSArray arrayWithObjects:@"a", @"b", @"c", nil];
    __emptySet = [NSSet setWithObjects:nil];
    __testSet = [NSSet setWithArray:__testArray];
    __testDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"aVal",@"aKey",  @"bVal",@"bKey",  @"cVal",@"cKey",  nil
    ];
}


- (void) testReduce {
    NSString* (^testAppend)(NSString*,NSString*) = ^(NSString* accum, NSString* x) {
        return  [accum stringByAppendingString:x];
    };
    NSArray* result = reduce( testAppend, @"-", __testArray );
    STAssertEqualObjects( result, @"-abc", @"Reduce should accumulate its result in left-to-right order." );
    result = reduce( testAppend, @"-", __emptyArray );
    STAssertEqualObjects( result, @"-", @"Reduce should just return initial value for empty array arg." );
}


- (void) testMap {
    NSString* (^testUpCase)(NSString*) = ^(NSString* x){
        return  [x uppercaseString];
    };
    NSArray* result = [NSSet setWithArray:map(testUpCase, __testSet)];
    STAssertEqualObjects( result, ([NSSet setWithObjects:@"A",@"B",@"C",nil]), @"Map should apply its function to each member of a set." );

    STAssertEqualObjects( map(testUpCase, __emptySet), __emptyArray, @"Map should map an empty set to an empty array." );

    result = map( testUpCase, nil );
    STAssertEqualObjects( result, __emptyArray, @"Map should return an empty array if its collection arg. is nil." );
}


- (void) testMap2 {
    NSArray* upCaseArray = [NSArray arrayWithObjects:@"A",@"B",nil];
    NSString* (^catenate)(NSString*,NSString*) = ^(NSString* x1, NSString* x2){
        return  [x1 stringByAppendingString:x2];
    };

    NSArray* result = map2( catenate, __testArray, upCaseArray );
    STAssertEqualObjects( result, ([NSArray arrayWithObjects:@"aA",@"bB",nil]), @"Map2 should apply its 2-arg. function to each member of each respective collection. Result should have same count as shortest collection." );

    result = map2( catenate, upCaseArray, __testArray );
    STAssertEqualObjects( result, ([NSArray arrayWithObjects:@"Aa",@"Bb",nil]), @"Map2 should apply its 2-arg. function to each member of each respective collection. Result should have same count as shortest collection." );

    result = map2( catenate, __testSet, __emptyArray );
    STAssertEqualObjects( result, __emptyArray, @"Map2 should return an empty array if one of its collection args. is empty." );

    result = map2( catenate, __testSet, nil );
    STAssertEqualObjects( result, __emptyArray, @"Map2 should return an empty array if one of its collection args. is nil." );

    result = map2( catenate, nil, __testSet );
    STAssertEqualObjects( result, __emptyArray, @"Map2 should return an empty array if one of its collection args. is nil." );

    result = map2( catenate, nil, nil );
    STAssertEqualObjects( result, __emptyArray, @"Map2 should return an empty array if both its collection args. are nil." );
}


- (void) testFilter {
    BOOL (^testPred)(NSString*) = ^(NSString* key){
        return [key isEqual:@"cKey"];
    };
    BOOL (^alwaysNo)(id) = ^(id x){ return NO; };

    NSArray* result = filter( testPred, __testDictionary );
    STAssertEqualObjects( result, [NSArray arrayWithObject:@"cKey"], @"Filter should return array of passing keys." );
    STAssertEqualObjects( filter(alwaysNo, __emptyArray), __emptyArray, @"Filter on always-failing predicate should return empty array." );
}


@end
