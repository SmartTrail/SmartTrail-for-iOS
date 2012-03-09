//
//  AppDelegate.m
//  SmartTrail
//
//  Created by Tyler Perkins on 2011-12-10.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()
@property (retain,nonatomic) NSArray* ratingImages;
UIImage* imageForPngNamed( NSString* filename );
@end


@implementation AppDelegate


@synthesize window = __window;
@synthesize bmaController = __bmaController;
@synthesize dataUtils = __dataUtils;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize ratingImages = __ratingImages;


- (BOOL)
                      application:(UIApplication*)application
    didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    __bmaController = [BMAController new];

    __dataUtils = [[CoreDataUtils alloc] initWithProvisions:self];

    self.ratingImages = [NSArray
        arrayWithObjects:
            imageForPngNamed(@"rating_dots_0"),
            imageForPngNamed(@"rating_dots_1"),
            imageForPngNamed(@"rating_dots_2"),
            imageForPngNamed(@"rating_dots_3"),
            imageForPngNamed(@"rating_dots_4"),
            imageForPngNamed(@"rating_dots_5"),
            nil
    ];
    NSAssert( self.ratingImages.count == 6, @"Couldn't load all five rating_dots_*.png files" );

    [__bmaController downloadAllTrailInfo];

    return YES;
}


- (void) applicationWillResignActive:(UIApplication*)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void) applicationDidEnterBackground:(UIApplication*)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}


- (void) applicationWillEnterForeground:(UIApplication*)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}


- (void) applicationDidBecomeActive:(UIApplication*)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void) applicationWillTerminate:(UIApplication*)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


- (void) saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Core Data stack


/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext*) managedObjectContext {
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel*) managedObjectModel {
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SmartTrail" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator*) persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }

    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SmartTrail.sqlite"];

    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.

         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.

         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.


         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.

         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]

         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.

         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return __persistentStoreCoordinator;
}


#pragma mark - Application's Documents directory & data there


/** Returns the URL to the application's Documents directory.
 */
- (NSURL*) applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager]
             URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask
             ] lastObject];
}


- (UIImage*)
    imageForRating:(NSUInteger)rating
           inRange:(NSUInteger)lo
           through:(NSUInteger)hi
{
    //  E.g., rating is in interval [0,10] & array index must be in [0,5]

    NSUInteger topIndex = self.ratingImages.count - 1;
    NSUInteger idx = lround( (rating - lo)*topIndex / ((float)(hi - lo)) );
    NSUInteger highest = [self.ratingImages count] - 1;
    NSUInteger index0Thru5 =  idx > highest  ?  highest  :  idx;
    return  [self.ratingImages objectAtIndex:index0Thru5];
}


#pragma mark - Private methods and functions


/** Returns a new, autoreleased instance of UIImage initialized with the
    contents of a PNG file of the given name (sans the ".png" extension). A file
    with that name and a ".png" extension will be searched for in the main
    bundle. For example, file rating_dots_0.png would be found in the resources
    directory, and an appropriate UIImage object would be returned.
*/
UIImage* imageForPngNamed( NSString* name ) {
    NSString* path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
    return  [UIImage imageWithContentsOfFile:path];
}


@end
