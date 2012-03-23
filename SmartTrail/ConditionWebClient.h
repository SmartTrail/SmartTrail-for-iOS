//
//  Created by tyler on 2012-03-22.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JSONWebClient.h"


@interface ConditionWebClient : JSONWebClient

/** Prepares the receiver to load all conditions for all trails in region 1.
*/
- (id) init;

/** Prepares the receiver to load all conditions for all trails in the indicated
    area.
*/
- (id) initWithAreaId:(NSInteger)areaId;

@end
