//
//  BMAController.h
//  SmartTrail
//
//  Created by Tyler Perkins on 2012-02-17.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/** This class is the central clearinghouse for BMA data obtained via a
    RESTfull web API. Methods invoked on its single instance offer services
    to GUI classes, often creating and persisting managed objects to hold the
    data. Thus, GUI classes usually don't receive the data directly, but
    are notified of changes to the saved data, and update their views
    accordingly.
*/
@interface BMAController : NSObject

/** Requests data from the BMA server, parses the returned JSON, and creates
    or updates suitable Area, Trail, and Condition managed objects representing
    the data. These changes are persisted, and the managed object context
    maintained by the application delegate is notified of any changes. Although
    this method returns immediately while its work is performed asyncronously,
    the managed objects are populated in an order that ensures relationships
    between them are correct.
*/
- (void) downloadAllTrailInfo;

/** Requests data from the BMA server, parses the returned JSON, and creates
    or updates suitable Event managed objects representing the data. These
    changes are persisted, and the managed object context maintained by the
    application delegate is notified of any changes. This method returns
    immediately while its work is performed asyncronously.
*/
- (void) downloadEvents;

@end
