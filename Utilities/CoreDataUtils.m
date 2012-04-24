//  Created by tyler on 2012-01-13.
//
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CoreDataUtils.h"
#import "CoreDataProvisions.h"
#import "NSString+Utils.h"

@interface CoreDataUtils ()
@property (retain,nonatomic) NSObject<CoreDataProvisions>* appDelegate;
@property (retain,nonatomic) id contextSaveObserver;
@end

static id descriptionOfValueIn(
    NSDictionary* dataDict, NSString* key, NSPropertyDescription* prop
);


@implementation CoreDataUtils


@synthesize context = __context;
@synthesize appDelegate = __appDelegate;
@synthesize contextSaveObserver = __contextSaveObserver;


- (void) dealloc {
    self.mergesWhenAnyContextSaves = NO;  // Removes notification from center.

    [__context release];                __context = nil;
    [__appDelegate release];            __appDelegate = nil;
    [__contextSaveObserver release];    __contextSaveObserver = nil;
    [super dealloc];
}


#pragma mark - Initialization


/** Convenience class method for instantiation.
*/
+ (id) coreDataUtilsWithProvisions:(NSObject<CoreDataProvisions>*)appDelegate {
    return  [[[self alloc] initWithProvisions:appDelegate] autorelease];
}


- (id) init {
    NSAssert( NO, @"The designated initializer, initWithProvisions:, must be called instead." );
    return  nil;
}


- (id) initWithProvisions:(NSObject<CoreDataProvisions>*)appDelegate {
    self = [super init];
    if ( self ) {
        self.appDelegate = appDelegate;
    }
    return  self;
}


#pragma mark - Accessors


/** If context property has not already been set, makes a new one.
*/
- (NSManagedObjectContext*) context {
    if ( ! __context ) {
        NSPersistentStoreCoordinator* coord =
            self.appDelegate.persistentStoreCoordinator;
        if ( coord ) {
            __context = [NSManagedObjectContext new];
            __context.persistentStoreCoordinator = coord;
        }
    }
    return  __context;
}


- (NSObject<CoreDataProvisions>*) appDelegate {
    if ( ! __appDelegate ) {
        self.appDelegate = (NSObject<CoreDataProvisions>*)[
            [UIApplication sharedApplication] delegate
        ];
    }
    return  __appDelegate;
}


- (BOOL) mergesWhenAnyContextSaves {
    return  self.contextSaveObserver != nil;
}


- (void) setMergesWhenAnyContextSaves:(BOOL)shouldListen {
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];

    if ( shouldListen  &&  ! self.contextSaveObserver ) {
        __block CoreDataUtils* unretained_self = self;

        //  Register a block to handle context save events. The returned
        //  observer id is needed only to unregister. See the "else if", below.
        //  We could have instead used method addObserver:selector:name:object:,
        //  for which we PROVIDE the observer, self.context, obviating the need
        //  for property contextSaveObserver. However, using a block has proven
        //  to be more flexible and easier to debug, since additional statements
        //  like NSLog(...) can be executed in the block.
        self.contextSaveObserver = [center
            addObserverForName:NSManagedObjectContextDidSaveNotification
                        object:nil
                         queue:nil
                    usingBlock:^( NSNotification* note ){
                        [unretained_self.context
                            mergeChangesFromContextDidSaveNotification:note
                        ];
                    }
        ];

    } else if ( ! shouldListen  &&  self.contextSaveObserver ) {
        [center removeObserver:self.contextSaveObserver];
        self.contextSaveObserver = nil;
    }
}


#pragma mark - Finding or collecting managed objects


- (NSFetchRequest*) requestFor:(NSString*)tmplName {
    NSFetchRequest* req = [self.appDelegate.managedObjectModel
        fetchRequestTemplateForName:tmplName
    ];

    NSAssert( req, @"Request template \"%@\" could not be found.", tmplName );
    return  req;
}


- (NSFetchRequest*)
               requestFor:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars
{
    NSFetchRequest* req = [self.appDelegate.managedObjectModel
        fetchRequestFromTemplateWithName:tmplName
                   substitutionVariables:substVars
    ];

    NSAssert( req, @"Request template \"%@\" could not be found.", tmplName );
    return  req;
}


- (NSFetchRequest*) requestFor:(NSString*)tmplName atId:(NSString*)idString {
    NSAssert( idString, @"Id string must not be nil." );

    NSFetchRequest* req = [self
                   requestFor:tmplName
        substitutionVariables:[NSDictionary
                                  dictionaryWithObject:idString
                                                forKey:@"id"
                              ]
    ];

    NSAssert( req, @"Request template \"%@\" could not be found.", tmplName );
    return  req;
}


- (NSManagedObject*) findTheOneUsingRequest:(NSFetchRequest*)req {
    NSArray* foundObjs = nil;
    ERR_ASSERT(
        foundObjs = [self.context executeFetchRequest:req error:&ERR];
    )
    NSAssert(
        [foundObjs count] <= 1,
        @"More than one managed object found satisfying request %@.",
        req
    );

    //  We've found 0 or one manage object.
    return  [foundObjs lastObject];
    //  Note that if foundObjs is empty, lastObject returned nil.
}


- (NSArray*) find:(NSString*)tmplName {
    NSFetchRequest* req = [self requestFor:tmplName];
    ERR_ASSERT(
        return  [self.context executeFetchRequest:req error:&ERR];
    )
}


- (NSArray*)         find:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars
{
    NSFetchRequest* req = [self
        requestFor:tmplName substitutionVariables:substVars
    ];
    ERR_ASSERT(
        return  [self.context executeFetchRequest:req error:&ERR];
    )
}


- (NSManagedObject*) findThe:(NSString*)tmplName at:(NSString*)idString {
    return  idString
    ?   [self findTheOneUsingRequest:[self requestFor:tmplName atId:idString]]
    :   nil;
}


- (NSInteger)
                  countOf:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars
{
    NSFetchRequest* req = [self
        requestFor:tmplName substitutionVariables:substVars
    ];
    ERR_ASSERT(
        return  [self.context countForFetchRequest:req error:&ERR];
    )
}


#pragma mark - Inserting new managed objects or updating existing ones


- (NSManagedObject*)
    updateOrInsertThe:(NSString*)tmplName
       withProperties:(NSDictionary*)propDict
          matchingKey:(NSString*)propName
{
    //  A nil propDict is OK, it just means "do nothing".
    if ( ! propDict )  return  nil;

    id idStr = [propDict objectForKey:propName];
    if ( !( [idStr isKindOfClass:[NSString class]]  &&  [idStr isNotBlank] ) ) {
        //  This might be acceptable, so only log a warning if we're in DEBUG
        //  mode. In any case, just return without doing anything.
#ifdef DEBUG
        NSLog(
            @"CoreDataUtils -updateOrInsertThe:withProperties:matchingKey:  Bad data. No key \"%@\" was found in the given dictionary or it had a bad value. No insert or update was done.",
            propName
        );
#endif
        return nil;
    }

    NSFetchRequest* req = [self
                   requestFor:tmplName
        substitutionVariables:[NSDictionary
                                  dictionaryWithObject:idStr
                                                forKey:propName
                              ]
    ];
    NSManagedObject* obj = [self findTheOneUsingRequest:req];
    if ( ! obj ) {
        //  No managed object with the given id was found. Create one.
        NSEntityDescription* entity = [req entity];
        obj = [[(NSManagedObject*)[NSClassFromString([entity name]) alloc]
                            initWithEntity:entity
            insertIntoManagedObjectContext:self.context
        ] autorelease];
    }

    //  Populate the managed object with the given properties.
    [obj setValuesForKeysWithDictionary:propDict];

    return  obj;
}


- (NSManagedObject*)
    updateOrInsertThe:(NSString*)tmplName
       withProperties:(NSDictionary*)propDict
{
    return  [self
        updateOrInsertThe:tmplName withProperties:propDict matchingKey:@"id"
    ];
}


- (PropConverter)
    dataDictToPropDictConverterForEntityName:(NSString*)entityName
                        usingFuncsByPropName:(NSDictionary*)funcsByPropName
{
    NSEntityDescription* entity = [NSEntityDescription
                 entityForName:entityName
        inManagedObjectContext:self.context
    ];
    NSAssert(
        entity,
        @"Could not find entity \"%@\". Entity names are case-sensitive.",
        entityName
    );
    NSDictionary* propertiesByName = [entity propertiesByName];
    NSArray* propertyNames = [propertiesByName allKeys];

    return  [[ ^(NSDictionary* dataDict) {

        //  The dictionary to be returned.
        NSMutableDictionary* newDataByPropName = [NSMutableDictionary
            dictionaryWithCapacity:[propertyNames count]
        ];

        //  For the name of each property in the entity, make a property value
        //  from dataDict and insert it into newDataByPropName. First look in
        //  funcsByPropName for a DataDictToPropVal function block associated
        //  with the name and use it to generate the value. If not found, use
        //  the function provided for key @"ANY OTHER PROPERTY". If still not
        //  found, just insert the value in dataDict associated with the
        //  property name. If dataDict has no value for that name, don't insert
        //  anything.
        //
        for ( NSString* propName in propertyNames ) {

            //  Get the DataDictToPropVal function to use to calculate the new
            //  prsoperty value. Use key @"ANY OTHER PROPERTY" if not found for
            //  specific property name.
            DataDictToPropVal func = [funcsByPropName objectForKey:propName];
            if ( ! func ) {
                func = [funcsByPropName objectForKey:AnyOtherProperty];
            }

            //  If we got a DataDictToPropVal function, do the calculation.
            //  Otherwise, just use the raw data for the property name.
            id newPropVal = func
            ?   func( dataDict, [propertiesByName objectForKey:propName] )
            :   [dataDict objectForKey:propName];

            if ( newPropVal ) {
                //  func returned a non-nil value. Add key/value to result.
                [newDataByPropName setObject:newPropVal forKey:propName];
            }
        }

        return  newDataByPropName;

    } copy ] autorelease];
}


#pragma mark - Deleting managed objects


- (NSInteger) deleteObjects:(NSArray*)objArray {
    for ( NSManagedObject* obj in objArray )  [self.context deleteObject:obj];
    return [objArray count];
}


- (NSInteger) delete:(NSString*)tmplName {
    return [self deleteObjects:[self find:tmplName]];
}


- (NSInteger)      delete:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars
{
    return [self
        deleteObjects:[self find:tmplName substitutionVariables:substVars]
    ];
}


#pragma mark - Saving the context


/** Save the managed object context. If there is an error, complain and stop if
    we're in DEBUG mode, otherwise just roll back the context.
*/
- (void) save {
    if ( [self.context hasChanges] ) {
        NSError* err = nil;
        [self.context save:&err];
        NSAssert( ! err, @"There are changes in the managed object context, but couldn't save them." );
    }
}


#pragma mark - Handy DataDictToPropVal function blocks


DataDictToPropVal fnRawForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, NSPropertyDescription* prop) {
        return  [dataDict objectForKey:dataKey?dataKey:[prop name]];
    } copy] autorelease];
}


DataDictToPropVal fnBoolForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, NSPropertyDescription* prop) {
        NSString* str = descriptionOfValueIn( dataDict, dataKey, prop );
        return  [NSNumber numberWithBool:[str boolValue]];
    } copy] autorelease];
}


DataDictToPropVal fnIntegerForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, NSPropertyDescription* prop) {
        NSString* str = descriptionOfValueIn( dataDict, dataKey, prop );
        return  [NSNumber numberWithInt:[str integerValue]];
    } copy] autorelease];
}


DataDictToPropVal fnStringForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, NSPropertyDescription* prop) {
        return  descriptionOfValueIn( dataDict, dataKey, prop );
    } copy] autorelease];
}


DataDictToPropVal fnFloatForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, NSPropertyDescription* prop) {
        NSString* str = descriptionOfValueIn( dataDict, dataKey, prop );
        return  [NSNumber numberWithFloat:[str floatValue]];
    } copy] autorelease];
}


DataDictToPropVal fnDateSince1970ForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, NSPropertyDescription* prop) {
        NSString* str = descriptionOfValueIn( dataDict, dataKey, prop );
        return  [NSDate dateWithTimeIntervalSince1970:[str doubleValue]];
    } copy] autorelease];
}


DataDictToPropVal fnCoerceDataKey( NSString *dataKey ) {
    NSNumberFormatter* numberFormatter = [[NSNumberFormatter new] autorelease];

    return  [[^(NSDictionary* dataDict, NSPropertyDescription* prop) {
        id propVal = nil;

        if ( [prop isKindOfClass:[NSAttributeDescription class]] ) {
            NSString* dataStr = descriptionOfValueIn( dataDict, dataKey, prop );

            switch ( [(NSAttributeDescription* )prop attributeType] ) {

              case NSStringAttributeType:
                propVal = dataStr;
              break;

              case NSInteger16AttributeType:
              case NSInteger32AttributeType:
              case NSInteger64AttributeType:
              case NSDoubleAttributeType:
              case NSFloatAttributeType:
                propVal = [numberFormatter numberFromString:dataStr];
              break;

              case NSBooleanAttributeType:
                propVal = [NSNumber numberWithBool:[dataStr boolValue]];
              break;

              case NSDecimalAttributeType:
                propVal = [NSDecimalNumber decimalNumberWithString:dataStr];
              break;
            }
        }
        return  propVal;
    } copy] autorelease];
}


DataDictToPropVal fnConstant( id valueToReturn ) {
    return  [[^(id _1, id _2) { return valueToReturn; } copy] autorelease];
}


#pragma mark - Private methods and functions


/** Return the value in dataDict for the given key, if key is non-nil.
    Otherwise, return the value associated with the name of the given
    property.
*/
id descriptionOfValueIn(
    NSDictionary* dataDict, NSString* key, NSPropertyDescription* prop
) {
    return [[dataDict objectForKey:key?key:[prop name]] description];
}


@end
