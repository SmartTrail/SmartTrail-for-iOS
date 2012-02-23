//
//  FetchedResults.h
//  Places
//
//  Created by Tyler Perkins on 2012-02-12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CoreDataUtils.h"

/** This class is just like NSFetchedResultsController, except that it adds an
    initializer for conveniently specifying attributes collected by an instance
    of FetchedResultsTableDataSource.
*/
@interface FetchedResults : NSFetchedResultsController

/** Convenience property for recalling the substitution variables dictionary
    provided to the initializer.
*/
@property (nonatomic,readonly) NSDictionary* substitutionVariables;

- (id)
    initWithDataUtils:(CoreDataUtils*)dataUtils
         templateName:(NSString*)tmplName
     substitutingVars:(NSDictionary*)substDict
             sortedBy:(NSString*)key1
            ascending:(BOOL)asc1
            isSection:(BOOL)isSect
               thenBy:(NSString*)key2
            ascending:(BOOL)asc2;

@end
