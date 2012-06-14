//
//  Created by tyler on 2012-03-19.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "JSONWebClient.h"
#import "JSONKit.h"


@implementation JSONWebClient
{
    CoreDataUtils* __dataUtils;
    NSString*      __entityName;
}


@synthesize dataDictsExtractor = __dataDictsExtractor;
@synthesize propConverter = __propConverter;


- (id) initWithDataUtils:(CoreDataUtils*)dataUtils entityName:(NSString*)name {
    self = [super init];
    if ( self ) {
        __dataUtils = dataUtils;
        __entityName = name;
    }
    return  self;
}


- (id) init {
    NSAssert( NO, @"The designated initializer, initWithDataUtils:entityName:, must be called instead." );
    return  nil;
}


#pragma mark - Getters that initialize public properties


/** If not already set, returns the default DataDictsExtractor. See the docs
    for this property in the JSONWebClient.h file. Assign your own
    DataDictsExtractor to this property or override this method, if necessary.
*/
- (DataDictsExtractor) dataDictsExtractor {
    if ( ! __dataDictsExtractor ) {
         NSString* entityNamePlural = [[__entityName lowercaseString]
            stringByAppendingString:@"s"
        ];

        self.dataDictsExtractor = ^(NSDictionary* parsedData) {
            return  [(NSDictionary*)[parsedData objectForKey:@"response"]
                objectForKey:entityNamePlural
            ];
        };
    }
    return __dataDictsExtractor;
}


/** If not already set, returns the default PropConverter.
*/
- (PropConverter) propConverter {
    if ( ! __propConverter ) {
        self.propConverter = [__dataUtils
            dataDictToPropDictConverterForEntityName:__entityName
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:
                    fnCoerceDataKey(nil), AnyOtherProperty,
                    nil                              ]
        ];
    }
    return  __propConverter;
}


#pragma mark - Overriding WebClient methods


- (BOOL) isOKToSendRequest {
    //  There is no default dataDictsExtractor block, so stop in DEBUG mode if
    //  there is a programming error neglecting this.
    NSAssert(
        self.dataDictsExtractor,
        @"The dataDictsExtractor property must be assigned a block."
    );

    //  If we're not in DEBUG mode and dataDictsExtractor is nil, the request
    //  will simply not be sent.
    return  self.dataDictsExtractor != nil;
}


/** Parses the given JSON data, drills down to the data array of interest, and
    with each dictionary element there, updates or inserts a managed object
    using its keys and values.
*/
- (void) processReceivedData:(NSData*)json {
    [super processReceivedData:json];
    if ( ! self.error ) {

        //  Parse the JSON into a data structure consisting of nested dictionaries
        //  and arrays.
        NSDictionary *parsedData = [[JSONDecoder decoder] objectWithData:json];
        NSAssert(
            parsedData,
            @"Received JSON data could not be parsed. Data as ASCII:\n\n%@\n",
            [[NSString alloc] initWithData:json encoding:NSASCIIStringEncoding]
        );

        //  By convention, the name of the fetch request template that finds an
        //  object by its ID is "<entity name>ForId".
        NSString* fetchReqName = [__entityName stringByAppendingString:@"ForId"];

        //  Drill down to the data array and process each data dictionary in it.
        //
        for ( NSDictionary* dataDict in self.dataDictsExtractor(parsedData) ) {
            //  Create or update a managed object loaded with data from dataDict.
            [__dataUtils
                updateOrInsertThe:fetchReqName
                   withProperties:self.propConverter(dataDict)
            ];
        }
    }
}


@end
