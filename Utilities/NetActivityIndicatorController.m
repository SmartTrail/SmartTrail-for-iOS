//
// Created by tyler on 2012-05-26.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "NetActivityIndicatorController.h"


@implementation NetActivityIndicatorController
{
    NSInteger __netActivitiesCount;
}


- (void) aNetActivityDidStart {
    dispatch_async( dispatch_get_main_queue(), ^{
        __netActivitiesCount++;
        if ( __netActivitiesCount > 0 ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    } );
}


- (void) aNetActivityDidStop {
    dispatch_async( dispatch_get_main_queue(), ^{
        __netActivitiesCount--;
        if ( __netActivitiesCount <= 0 ) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    } );
}


@end
