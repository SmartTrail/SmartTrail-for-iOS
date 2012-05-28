//
//  Created by tyler on 2012-01-13.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>
#import "CoreDataProvisions.h"


/** Dictionaries of DataDictToPropVal function blocks keyed by property name
    are used to define how to calculate the value to assign to the property of
    that name. Each such function takes the entire data dictionary as argument,
    allowing it to use any of its values in the calculation. The same
    DataDictToPropVal could be used for several properties, so the property's
    description is provided so the function can customize its result.
*/
typedef id (^DataDictToPropVal)(
    NSDictionary* dataDict,         // Data to convert into a managed object.
    NSPropertyDescription* prop     // Returns value for this kind of property.
);


/** A PropConverter, as used by this class, is just a function block that
    converts a dictionary of raw data into another dictionary, whose keys and
    values are suitable to use to populate a particular kind of managed object.
    That is, the returned dictionary must be suitable to use as an argument to
    the NSKeyValueCoding protocol's method setValuesForKeysWithDictionary:.
*/
typedef NSDictionary* (^PropConverter)(NSDictionary* dataDict);


/** Useful to use as a key in the dictionary parameter passed to method
    dataDictToPropDictConverterForEntityName:usingFuncsByPropName: to indicate
    that its associated value, a function block, will be used to calculate
    values for all properties whose names are not keys in the dictionary.
*/
static NSString* AnyOtherProperty = @"ANY OTHER PROPERTY";


@interface CoreDataUtils : NSObject


/** Unless assigned-to, this property returns a newly created managed object
    context.  This is important when using the receiver to work with Core Data
    in another thread. In the new thread, create a new instance of this class
    and just don't assign to the context property. This will force this method
    to create a new context just for the thread, as required by Core Data.
*/
@property (retain,nonatomic) NSManagedObjectContext* context;


/** Setting to YES causes self.context to listen for notifications named
    NSManagedObjectContextDidSaveNotification. These are posted when any
    NSManagedObjectContext's save: method is invoked (and thus, also when any
    CoreDataUtils's save method is invoked). When the notification is received,
    self.context merges the changes into itself. By default, this property's
    value is NO. After having set this property to YES, you can later set it to
    NO, which will cause self.context to stop listening.
*/
@property (assign,nonatomic) BOOL mergesWhenAnyContextSaves;


#pragma mark - Initialization


/** Creates and returns an autoreleased CoreDataUtils instance.
*/
+ (id) coreDataUtilsWithProvisions:(NSObject<CoreDataProvisions>*)appDelegate;


/** Do not use this method, it is disabled. Use the designated initializer
    instead.
*/
- (id) init;


/** Designated initializer.
*/
- (id) initWithProvisions:(NSObject<CoreDataProvisions>*)appDelegate;


#pragma mark - Finding or collecting managed objects


/** Returns the NSEntityDescription of the entity with the given name. When
    inserting a new managed object instantiated with NSManageObject's
    initWithEntity:insertIntoManagedObjectContext: method, you should not
    obtain the entity from a fetch request created from a template, say like
    [[aManagedObjectModel fetchRequestTemplateForName:@"aName"] entity]. I
    have not seen this documented anywhere, but it seems that the entity
    description object in a relation of an entity so created may not be the same
    object as the one known to a managed object you obtain by way of a fetch.
    Maybe the mechanism for generating a fetch request from a template is
    caching old entity objects. At any rate, this will cause an exception at
    least when you try to insert a new managed object that has a to-one
    relation. The relation's destination entity "isEqual:' to the entity of the
    fetched object, but they may not be "==". It seems like this should be OK,
    but may be a bug.

    If you use this method instead, the entity description is ultimately
    derived from self.context, so should be the same entity description object
    known to an object obtained by performing a fetch on that entity in
    self.context.
*/
- (NSEntityDescription*) entityForName:(NSString*)name;


/** Obtains the fetch request defined by the indicated fetch request template.
    An assertion will fail if no such template can be found.
*/
- (NSFetchRequest*) requestFor:(NSString*)tmplName;


/** Obtains the fetch request defined by the indicated fetch request template
    and populated with the given substitution variables. If the template has no
    substitution variables, pass nil for the second parameter. An assertion will
    fail if no such template can be found.
*/
- (NSFetchRequest*)
               requestFor:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars;


/** Convenience method to generate a request that searches by the "id" property.
    It is the same as calling requestFor:substitutionVariables: with a
    dictionary that just has a string value for key "id". Note that the key is
    case sensitive. By convention, the fetch request template is named, for
    example, YourEntityForId, where you have defined an entity named
    "YourEntity". The request template's entity should be set to "YourEntity",
    and it must have the predicate expression "id == $id". (FYI, the first "id"
    is the name of the entity's property, and the "$id" variable name matches
    the key "id" in the given dictionary.)
*/
- (NSFetchRequest*) requestFor:(NSString*)tmplName atId:(NSString*)idString;


/** Runs the given request and returns the single managed object it finds, or
    nil if none is found. If more than one object is found, an assertion is
    violated.
*/
- (NSManagedObject*) findTheOneUsingRequest:(NSFetchRequest*)req;


/** Given the name of a request template, which must be as described above for
    method requestFor:atId:, this method runs the indicated request and returns
    all managed objects it finds, or nil if none are found. This provides an
    easy way to run a request template having no substitution variables. If an
    error occurs, returns nil. If no objects match the criteria specified by
    request, returns an empty array.
*/
- (NSArray*) find:(NSString*)tmplName;


/** Given the name of a request template, which must be as described above for
    method requestFor:atId:, this method runs the indicated request with the
    given substitution variables and returns all managed objects it finds, or
    nil if none are found. If an error occurs, returns nil. If no objects match
    the criteria specified by request, returns an empty array.
*/
- (NSArray*)         find:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars;


/** Given the name of a request template, which must be as described above for
    method requestFor:atId:, this method returns the managed object whose "id"
    attribute is equal to the given ID string. If no such object is found, nil
    is returned. If more than one is found, an assertion is violated.
*/
- (NSManagedObject*) findThe:(NSString*)tmplName at:(NSString*)idString;


- (NSInteger)
                  countOf:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars;


#pragma mark - Inserting new managed objects or updating existing ones


/** Given the name of a request template, this method looks up the managed
    object whose propName property is equal to the value in the given dictionary
    for key propName. If none is found, a new managed object is created whose
    class is indicated by the name of the request template's entity. The managed
    object is then populated using the keys and values in the dictionary, and
    its address is returned.

    Note that every key in the dictionary must be the name of a property in the
    entity, or an NSUnknownKeyException will be thrown. (To deal with this, use
    method dataDictToPropDictConverterForEntityName:usingFuncsByPropName:.)

    Passing a nil propDict dictionary is OK, and is just interpreted to mean,
    "Do nothing, just return nil". The dictionary returned by a validation
    method could be passed, for example. It could return nil to indicate that
    the data should not be used.

    If your propDict is not nil, but it does not contain a key equal to
    propName, then, as above, nothing is done and nil is returned. If we're
    running in DEBUG mode (the DEBUG macro is defined), then a warning message
    is logged.
*/
- (NSManagedObject*)
    updateOrInsertThe:(NSString*)tmplName
       withProperties:(NSDictionary*)propDict
          matchingKey:(NSString*)propName;


/** Equivalent to method updateOrInsertThe:withProperties:matchingKey: with
    the matchingKey: argument "id", by convention. The indicated request
    template and its entity's propName property must be as described above for
    method requestFor:atId:.
*/
- (NSManagedObject*)
    updateOrInsertThe:(NSString*)tmplName
       withProperties:(NSDictionary*)propDict;


/** This method creates a PropConverter, which is a function taking a
    dictionary and returning a dictionary. It may be used to provide a cleaned-
    up dictionary to methods like updateOrInsertThe:withProperties:matchingKey:
    that use the KVC method setValuesForKeysWithDictionary: to populate a
    managed object. The input of the returned PropConverter will be raw data
    values keyed by strings, and its output will be values suitable for
    assignment to an entity's properties, keyed by the entity's property names.
    As input, this method takes entityName, the entity's name, along with
    funcsByPropName, a dictionary of DataDictToPropVal functions keyed by the
    entity's property names. The DataDictToPropVal functions will do the work of
    deriving a particular property's value given the raw data dictionary and the
    property's description. If a key's DataDictToPropVal function returns nil,
    the dictionary returned by the resulting PropConverter will have no value
    for that key.

    If funcsByPropName is nil, then the resulting PropConverter function does no
    converting. The set of keys of the dictionary returned by the PropConverter
    will simply be the intersection of the set of the entity's property names
    and the set of keys of the input raw data dictionary. The values will just
    be looked up in the data dictionary. This is useful because you usually need
    a dictionary that has no key that is not the name of a property in the
    entity.

    The returned PropConverter is autoreleased.
*/
- (PropConverter)
    dataDictToPropDictConverterForEntityName:(NSString*)entityName
                        usingFuncsByPropName:(NSDictionary*)funcsByPropName;


#pragma mark - Deleting managed objects


/** Deletes every member of the given array of NSManagedObject instances, and
    returns the number deleted.
*/
- (NSInteger) deleteObjects:(NSArray*)objArray;


/** Given the name of a request template, which must be as described above for
    method requestFor:atId:, this method finds managed objects using the
    indicated request and deletes them. The number deleted is returned.
*/
- (NSInteger) delete:(NSString*)tmplName;


/** Given the name of a request template, which must be as described above for
    method requestFor:atId:, this method finds managed objects using the
    indicated request and substitution variables and deletes them. The
    number deleted is returned.
*/
- (NSInteger)      delete:(NSString*)tmplName
    substitutionVariables:(NSDictionary*)substVars;


#pragma mark - Saving the context


- (void) save;


#pragma mark - Handy DataDictToPropVal function blocks


/****
    The following fn... functions are provided to conveniently produce a
    function block to use as a value in the dictionary sent to method
    dataDictToPropDictConverterForEntityName:usingFuncsByPropName:.
    The dataKey argument specifies the key in the data dictionary to look
    up a raw value. Each function, which is used by the method to calculate a
    value to assign to a property, will transform the raw value into a type
    indicated by its name. You can always pass a nil dataKey to use the
    property's name as the key in the data dictionary.
****/


/** The returned DataDictToPropVal function will do no conversion, but will
    simply return the value for dataKey (or the property's name, if nil) in the
    data dictionary argument sent to the PropConverter function generated by
    that method. It is returned autoreleased.
*/
DataDictToPropVal fnRawForDataKey( NSString *dataKey );


/** These functions are like fnRawForDataKey, above, returning a
    DataDictToPropVal function to convert the value for the dataKey string (or
    the property's name, if nil). This data dictionary value is converted into
    a value of the type indicated by the function's name. Normally, the data
    dictionary value will be a string, but in case it isn't, the string returned
    by its description method is used for the conversion.
*/
DataDictToPropVal fnBoolForDataKey( NSString *dataKey );
DataDictToPropVal fnIntegerForDataKey( NSString *dataKey );
DataDictToPropVal fnStringForDataKey( NSString *dataKey );
DataDictToPropVal fnFloatForDataKey( NSString *dataKey );
DataDictToPropVal fnDateSince1970ForDataKey( NSString *dataKey );


/** Returns a block that tries to transform the value in the data dictionary
    for key dataKey (or for the property's name, if nil) into a value suitable
    for the property being populated. This is convenient when calling it with a
    nil argument for key ANY_OTHER_PROPERTY in the dictionary argument of method
    dataDictToPropDictConverterForEntityName:usingFuncsByPropName:.
    This effectively ensures that properties not explicitly named by a key in
    the dictionary argument will be assigned values of the correct type.
    Only properties of string, boolean, or number types are coerced. Others
    will not be assigned to the property.
*/
DataDictToPropVal fnCoerceDataKey( NSString *dataKey );


/** This is just a function that returns a DataDictToPropVal function that
    always returns the given value. This is handy if you just want the value
    for one of your keys to be a particular value, regardless of the data
    dictionary.
*/
DataDictToPropVal fnConstant( id valueToReturn );


@end
