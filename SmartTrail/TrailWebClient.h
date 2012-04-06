//
//  Created by tyler on 2012-03-21.
//
//


#import <Foundation/Foundation.h>
#import "JSONWebClient.h"


@interface TrailWebClient : JSONWebClient

/** Prepares the receiver to load all trails in the indicated region. Always
    pass a CoreDataUtils instance created in the current thread.
*/
- (id) initWithDataUtils:(CoreDataUtils*)utils regionId:(NSInteger)regionId;

@end
