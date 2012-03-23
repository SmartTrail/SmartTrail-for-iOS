//
//  Created by tyler on 2012-03-19.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "JSONWebClient.h"
#import "JSONKit.h"
#import "NSHTTPURLResponse+Utils.h"


@interface JSONWebClient ()
@property (retain,nonatomic)           CoreDataUtils*   dataUtils;
@property (copy,nonatomic)             NSString*        entityName;
@property (retain,nonatomic)           NSURLConnection* urlConnection;
@property (readwrite,assign,nonatomic) BOOL             isUsed;
@property (readwrite,retain,nonatomic) NSDate*          serverTime;
@property (readwrite,retain,nonatomic) NSError*         error;
@property (retain,nonatomic)           NSMutableData*   receivedJSON;
NSMutableURLRequest* requestGET( NSString* urlString );
- (BOOL) checkAndSetUsed;
- (void) processJSONAndStore:(NSData*)json;
@end


@implementation JSONWebClient


@synthesize dataUtils = __dataUtils;
@synthesize entityName = __entityName;
@synthesize urlConnection = __urlConnection;
@synthesize urlString = __urlString;
@synthesize dataDictsExtractor = __dataDictsExtractor;
@synthesize propConverter = __propConverter;
@synthesize isUsed = __isUsed;
@synthesize serverTime = __serverTime;
@synthesize error = __error;
@synthesize receivedJSON = __receivedJSON;


- (void) dealloc {
    [__dataUtils release];          __dataUtils = nil;
    [__entityName release];         __entityName = nil;
    [__urlConnection release];      __urlConnection = nil;
    [__urlString release];          __urlString = nil;
    [__dataDictsExtractor release]; __dataDictsExtractor = nil;
    [__propConverter release];      __propConverter = nil;
    [__serverTime release];         __serverTime = nil;
    [__error release];              __error = nil;
    [__receivedJSON release];       __receivedJSON = nil;

    [super dealloc];
}


- (id) initWithDataUtils:(CoreDataUtils*)dataUtils entityName:(NSString*)name {
    self = [super init];
    if ( self ) {
        self.dataUtils = dataUtils;
        self.entityName = name;
    }
    return  self;
}


#pragma mark - Getters that initialize public properties


/** If not already set, returns the default DataDictsExtractor. See the docs
    for this property in the JSONWebClient.h file. Assign your own
    DataDictsExtractor to this property or override this method, if necessary.
*/
- (DataDictsExtractor) dataDictsExtractor {
    if ( ! __dataDictsExtractor ) {
         NSString* entityNamePlural = [[self.entityName lowercaseString]
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
        self.propConverter = [self.dataUtils
            dataDictToPropDictConverterForEntityName:self.entityName
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:
                    fnCoerceDataKey(nil), AnyOtherProperty,
                    nil                              ]
        ];
    }
    return  __propConverter;
}


#pragma mark - Requesting the data


- (void) sendSynchronousGet {
    if ( [self checkAndSetUsed] )  return;
    NSAssert( self.dataDictsExtractor, @"The dataDictsExtractor property must be assigned a block." );

    NSHTTPURLResponse* response = nil;
    NSError* err = nil;

    NSData* jsonData = [NSURLConnection
        sendSynchronousRequest:requestGET(self.urlString)
             returningResponse:&response
                         error:&err
    ];
    self.error = err;
    self.serverTime = [response date];
    [self processJSONAndStore:jsonData];
}


- (void) sendAsynchronousGet {
    if ( [self checkAndSetUsed] )  return;
    NSAssert( self.dataDictsExtractor, @"The dataDictsExtractor property must be assigned a block." );

    //  Send off the asynchronous request now.
    self.urlConnection = [NSURLConnection
        connectionWithRequest:requestGET(self.urlString) delegate:self
    ];
}


- (void) cancel {
    [self.urlConnection cancel];
}


#pragma mark - NSURLConnection delegate methods


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    [self.receivedJSON appendData:data];
}


- (void)
            connection:(NSURLConnection*)connection
    didReceiveResponse:(NSHTTPURLResponse*)response
{
    self.serverTime = [response date];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self processJSONAndStore:self.receivedJSON];
//  TODO  Use KVO to notify listeners.
}


- (void)
          connection:(NSURLConnection*)connection
    didFailWithError:(NSError*)error
{
    self.error = error;
//  TODO  Use KVO to notify listeners.
}


#pragma mark - Private methods and functions


/** Makes an autoreleased "GET" request with a URL from the given string.
*/
NSMutableURLRequest* requestGET( NSString* urlString ) {
    NSMutableURLRequest* request = [[NSMutableURLRequest new] autorelease];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    return  request;
}


/** Getter for private property receivedJSON that initializes it on first call.
*/
- (NSMutableData*) receivedJSON {
    if ( ! __receivedJSON ) {
        self.receivedJSON = [NSMutableData dataWithCapacity:2048];
    }
    return  __receivedJSON;
}


/** If the receiver's isUsed flag is YES, an assertion fails in DEBUG mode. In
    any case, the flag's value will be YES on return, but the returned BOOL will
    be its old value. Thus, since nothing else touches the flag, all subsequent
    calls result in the assertion failure and return YES.
*/
- (BOOL) checkAndSetUsed {
    BOOL wasUsed = self.isUsed;
    if ( wasUsed ) {
        NSAssert( NO, @"This WebClient instance has already been used. Create a new one." );
    } else {
        self.isUsed = YES;
    }
    return  wasUsed;
}


/** Parses the given JSON data, drills down to the data array of interest, and
    with each dictionary element there, updates or inserts a managed object
    using its keys and values.
*/
- (void) processJSONAndStore:(NSData*)json {

    //  Parse the JSON into a data structure consisting of nested dictionaries
    //  and arrays.
    NSDictionary *parsedData = [[JSONDecoder decoder] objectWithData:json];

    //  By convention, the name of the fetch request template that finds an
    //  object by its ID is "<entity name>ForId".
    NSString* fetchReqName = [self.entityName stringByAppendingString:@"ForId"];

    //  Drill down to the data array and process each data dictionary in it.
    //
    for ( NSDictionary* dataDict in self.dataDictsExtractor(parsedData) ) {
        //  Create or update a managed object loaded with data from dataDict.
        [self.dataUtils
            updateOrInsertThe:fetchReqName
               withProperties:self.propConverter(dataDict)
        ];
    }
}


@end
