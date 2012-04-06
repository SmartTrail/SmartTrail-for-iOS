//
//  Created by tyler on 2012-03-23.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "JSONWebClient.h"


@interface EventWebClient : JSONWebClient

/** Prepares the receiver to load all events in the indicated region. Always
    pass a CoreDataUtils instance created in the current thread.
*/
- (id) initWithDataUtils:(CoreDataUtils*)utils regionId:(NSInteger)regionId;

@end
