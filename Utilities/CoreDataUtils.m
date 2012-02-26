//
//  Created by tyler on 2012-01-13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "CoreDataUtils.h"
#import "CoreDataProvisions.h"

@interface CoreDataUtils ()
@property (nonatomic,retain) NSObject<CoreDataProvisions>* appDelegate;
@end


@implementation CoreDataUtils


@synthesize appDelegate = __appDelegate;


- (void) dealloc {
    [__appDelegate release];  __appDelegate = nil;
    [super dealloc];
}


#pragma mark - Accessors


/** For the context readonly property.
*/
- (NSManagedObjectContext*) context {
    return  self.appDelegate.managedObjectContext;
}


- (NSObject<CoreDataProvisions>*) appDelegate {
    if ( ! __appDelegate ) {
        self.appDelegate = (NSObject<CoreDataProvisions>*)[
            [UIApplication sharedApplication] delegate
        ];
    }
    return  __appDelegate;
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


#pragma mark - Finding or collecting managed objects


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


- (NSManagedObject*) findThe:(NSString*)tmplName at:(NSString*)idString {
    return
        [self findTheOneUsingRequest:[self requestFor:tmplName atId:idString]];
}


#pragma mark - Inserting new managed objects or updating existing ones


- (NSManagedObject*)
    updateOrInsertThe:(NSString*)tmplName
       withProperties:(NSDictionary*)propDict
          matchingKey:(NSString*)propName
{
    NSString* idStr = [propDict objectForKey:propName];
    NSAssert( idStr, @"No entry for key \"%@\" was found in the given dictionary.", propName );

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
    NSAssert1(
        entity,
        @"Could not find entity \"%@\". Entity names are case-sensitive.",
        entityName
    );
    NSDictionary* propertiesByName = [entity propertiesByName];
    NSArray* propertyNames = [propertiesByName allKeys];

    return  [[ ^(NSDictionary* dataDict) {

        NSMutableDictionary* newDataByPropName = [NSMutableDictionary
            dictionaryWithCapacity:[propertyNames count]
        ];

        //  For the name of each property in the entity, look in funcsByPropName
        //  for a DataDictToPropVal block associated with it. If found, have it
        //  generate a new property value from dataDict (and perhapse also from
        //  the description of the property of that name). If not found, just
        //  use the value in dataDict associated with the name.
        //
        for ( NSString* propName in propertyNames ) {

            DataDictToPropVal func = [funcsByPropName objectForKey:propName];
            id newPropVal = func
                //  If func provided for name, then process dataDict.
            ?   func( dataDict, [propertiesByName objectForKey:propName] )
                //  Else, use raw data value for propName.
            :   [dataDict objectForKey:propName];

            if ( newPropVal ) {
                [newDataByPropName setObject:newPropVal forKey:propName];
            }
        }

        return  newDataByPropName;

    } copy ] autorelease];
}


#pragma mark - Handy DataDictToPropVal function blocks


DataDictToPropVal fnRawForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, id _) {
        return  [dataDict objectForKey:dataKey];
    } copy] autorelease];
}


DataDictToPropVal fnBoolForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, id _) {
        NSString* str = [dataDict objectForKey:dataKey];
        return  [NSNumber numberWithBool:[str boolValue]];
    } copy] autorelease];
}


DataDictToPropVal fnIntForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, id _) {
        NSString* str = [dataDict objectForKey:dataKey];
        return  [NSNumber numberWithInt:[str boolValue]];
    } copy] autorelease];
}


DataDictToPropVal fnFloatForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, id _) {
        NSString* str = [dataDict objectForKey:dataKey];
        return  [NSNumber numberWithFloat:[str floatValue]];
    } copy] autorelease];
}


DataDictToPropVal fnDateSince1970ForDataKey( NSString *dataKey ) {
    return  [[^(NSDictionary* dataDict, id _) {
        NSString* str = [dataDict objectForKey:dataKey];
        return  [NSDate dateWithTimeIntervalSince1970:[str doubleValue]];
    } copy] autorelease];
}


@end
