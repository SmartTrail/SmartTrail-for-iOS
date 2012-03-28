//
//  Event+Display.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-03-26.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Event.h"

@interface Event (Display)

/** Create a succinct, human-readable string representation of the range of
    date/times from self.startAt to self.endAt.
*/
- (NSString*) dateRangeString;

@end
