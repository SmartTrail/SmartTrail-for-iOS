//
//  Created by tyler on 2011-12-17.
//
// To change the template use AppCode | Preferences | File Templates.
//


@protocol CoreDataProvisions

@property (nonatomic,readonly)
    NSManagedObjectModel*         managedObjectModel;
@property (nonatomic,readonly)
    NSPersistentStoreCoordinator* persistentStoreCoordinator;

@end
