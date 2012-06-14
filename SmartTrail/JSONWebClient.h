//
//  Created by tyler on 2012-03-19.
//
//


#import <Foundation/Foundation.h>
#import "WebClient.h"
#import "CoreDataUtils.h"


/** A DataDictsExtractor is a block taking a dictionary of all the data parsed
    from the JSON provided by the server. It returns an array of data
    dictionaries, typically an array which is just the value for some key in the
    JSON. Each data dictionary will be used to populate a managed object.
*/
typedef NSArray* (^DataDictsExtractor)(NSDictionary*);


/** This class is responsible for issuing a request to a RESTfull web service,
    loading the returned JSON data, and using it to update or insert a series
    of managed objects of a particular entity. This sequence may be conducted
    synchronously or asynchronously, but can be done only once. See the
    superclass' header file, WebClient.h, for more details.
*/
@interface JSONWebClient : WebClient

/** A function block to pull the array of data dictionaries out of parsed JSON.
    See the definition of DataDictsExtractor, above. If no value is assigned to
    this property, the default DataDictsExtractor function block just drills
    down two levels. It drills into the "response" dictionary in the parsed JSON
    data, then returns the array at a key based on the the receiver's entity
    name. The name is lowercased and an "s" is appended to it. This default is
    just a guess, and there is no established convention this key will work.
    If you assign a different DataDictsExtractor to this property, do so before
    calling a "send..." method.
*/
@property (copy,nonatomic) DataDictsExtractor  dataDictsExtractor;

/** A function block to convert a data dictionary into a dictionary suitable
    for populating a managed object. (Such objects have the entity determined by
    the entity name provided to method initWithDataUtils:entityName:.) If no
    value is assigned to this property, the default PropConverter just tries to
    coerce a data dictionary's values into values for properties of the managed
    object. The value is found in the dictionary at the key equal to the
    property's name.
*/
@property (copy,nonatomic) PropConverter       propConverter;

/** Initializes the receiver with the given CoreDataUtils, which will be used to
    update/insert a number of managed objects with downloaded JSON data. The
    objects will all be in the entity (and class) with the given name. This is
    the designated initializer.
*/
- (id) initWithDataUtils:(CoreDataUtils*)dataUtils entityName:(NSString*)name;

/** Overrides the superclass version to just fail an assertion if called in
    DEBUG mode. You must call the designated initializer, above.
*/
- (id) init;

@end
