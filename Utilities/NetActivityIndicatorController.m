//
// Created by tyler on 2012-05-26.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NetActivityIndicatorController.h"

static NSInteger NetActivitiesCount = 0;


@implementation NetActivityIndicatorController


+ (id) alloc {
    NSAssert(
        NO,
        @"Class NetActivityIndicatorController is not intended to be instantiated."
    );
    return nil;
}


+ (void) aNetActivityDidStart {
    dispatch_async( dispatch_get_main_queue(), ^{
        NetActivitiesCount++;
        if ( NetActivitiesCount > 0 ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    } );
}


+ (void) aNetActivityDidStop {
    dispatch_async( dispatch_get_main_queue(), ^{
        NetActivitiesCount--;
        if ( NetActivitiesCount <= 0 ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } );
}


@end
