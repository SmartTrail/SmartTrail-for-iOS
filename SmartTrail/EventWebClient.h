//
//  Created by tyler on 2012-03-23.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JSONWebClient.h"


@interface EventWebClient : JSONWebClient

/** Prepares the receiver to load all events in region ID 1.
*/
- (id) init;

/** Prepares the receiver to load all events in the indicated region.
*/
- (id) initWithRegionId:(NSInteger)regionId;

@end
