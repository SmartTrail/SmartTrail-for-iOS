//
//  Created by tyler on 2012-03-21.
//
//


#import <Foundation/Foundation.h>
#import "JSONWebClient.h"


@interface TrailWebClient : JSONWebClient


/** Prepares the receiver to load all trails in region ID 1.
*/
- (id) init;


/** Prepares the receiver to load all trails in the indicated region.
*/
- (id) initWithRegionId:(NSInteger)regionId;


@end
