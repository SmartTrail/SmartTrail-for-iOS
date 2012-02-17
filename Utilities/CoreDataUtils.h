//
//  Created by tyler on 2012-01-13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "CoreDataProvisions.h"


@interface CoreDataUtils : NSObject


/** Convenience property to get the NSManagedObjectContext provided by the
    CoreDataProvisions (usually the application delegate).
*/
@property (readonly) NSManagedObjectContext* context;

+ (id) coreDataUtilsWithProvisions:(NSObject<CoreDataProvisions>*)appDelegate;

/** Designated initializer.
*/
- (id) initWithProvisions:(NSObject<CoreDataProvisions>*)appDelegate;

- (NSManagedObject*)
    findThe:(NSString*)tmplName
         at:(NSString*)idString
      error:(NSError**)error;

- (NSManagedObject*)
    updateOrInsertThe:(NSString*)tmplName
                   at:(NSString*)idString
       withAttributes:(NSDictionary*)attrDict
                error:(NSError**)errAddr;

- (NSFetchRequest*)
               requestFor:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars;

- (NSFetchRequest*) requestFor:(NSString*)tmplName atId:(NSString*)idString;

- (NSManagedObject*)
    findTheOneUsingRequest:(NSFetchRequest*)req
                     error:(NSError**)error;


@end
