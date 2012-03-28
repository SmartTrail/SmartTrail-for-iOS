//
//  Created by tyler on 2012-03-20.
//
//


#import <Foundation/Foundation.h>
#import "JSONWebClient.h"


@interface AreaWebClient : JSONWebClient

/** Prepares the receiver to load all areas in region ID 1.
*/
- (id) init;

/** Prepares the receiver to load all areas in the indicated region.
*/
- (id) initWithRegionId:(NSInteger)regionId;

@end
