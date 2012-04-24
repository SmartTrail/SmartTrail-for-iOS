//
//  Created by tyler on 2012-03-22.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JSONWebClient.h"


@interface ConditionWebClient : JSONWebClient

/** Prepares the receiver to load all conditions in the indicated region. Always
    pass a CoreDataUtils instance created in the current thread.
*/
- (id) initWithDataUtils:(CoreDataUtils*)utils regionId:(NSInteger)regionId;

/** Prepares the receiver to load all conditions in the indicated area. Note
    that the id is a string, not an integer. Always pass a CoreDataUtils
    instance created in the current thread.
*/
- (id) initWithDataUtils:(CoreDataUtils*)utils areaId:(NSString*)areaId;

@end
