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


@interface CoreDataUtils : NSObject


/** Convenience property to get the NSManagedObjectContext provided by the
    CoreDataProvisions (usually the application delegate). Its value is
    obtained when this instance is initialized and is immutable. If you need
    to change the context, create a new instance of this class.
*/
@property (readonly) NSManagedObjectContext* context;


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


/** Obtains the fetch request defined by the indicated fetch request template
    and populated with the given substitution variables. If the template has no
    substitution variables, pass nil for the second parameter.
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
    method requestFor:atId:, this method returns the managed object whose "id"
    attribute is equal to the given ID string. If no such object is found, nil
    is returned. If more than one is found, an assertion is violated.
*/
- (NSManagedObject*) findThe:(NSString*)tmplName at:(NSString*)idString;


#pragma mark - Inserting new managed objects or updating existing ones


/** Given the name of a request template, this method looks up the managed
    object whose propName property is equal to the value in the given dictionary
    for key propName. If none is found, a new managed object is created whose
    class is indicated by the name of the request template's entity. The managed
    object is then populated using the keys and values in the dictionary. Note
    that every key in the dictionary must be the name of a property in the
    entity, or an NSUnknownKeyException will be thrown. (To deal with this, use
    method dataDictToPropDictConverterForEntityName:usingFuncsByPropName:.)
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


#pragma mark - Handy DataDictToPropVal function blocks


/** Convenience method to produce a function block to use as a value in the
    dictionary sent to method
    dataDictToPropDictConverterForEntityName:usingFuncsByPropName:.
    The returned DataDictToPropVal function will do no conversion, but will
    simply return the value for dataKey in the data dictionary argument sent
    to the PropConverter function generated by that method. It is returned
    autoreleased.
*/
DataDictToPropVal fnRawForDataKey( NSString *dataKey );


/** Convenience methods for creating frequently used function blocks. These are
    like fnRawForDataKey, above, except that each returned DataDictToPropVal
    block will convert the dataKey string into a value of the type suitable for
    a managed object's attribute.
*/
DataDictToPropVal fnBoolForDataKey( NSString *dataKey );
DataDictToPropVal fnIntForDataKey( NSString *dataKey );
DataDictToPropVal fnFloatForDataKey( NSString *dataKey );
DataDictToPropVal fnDateSince1970ForDataKey( NSString *dataKey );


/** This is just a function that returns a DataDictToPropVal function that
    always returns the given value. This is handy if you just want the value
    for one of your keys to be a particular value, regardless of the data
    dictionary.
*/
DataDictToPropVal fnConstant( id valueToReturn );


@end
