//
//  Created by tyler on 2012-03-30.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "WebClient.h"
#import "NSHTTPURLResponse+Utils.h"


@interface WebClient ()
@property (readwrite,assign,nonatomic)  BOOL            isUsed;
@property (readwrite,strong,nonatomic)  NSDate*         serverTime;
@property (readwrite,strong,nonatomic)  NSError*        error;
@property (strong,nonatomic)            NSMutableData*  receivedData;
- (NSMutableURLRequest*) requestWithMethod:(NSString*)method;
- (BOOL) checkAndSetUsed;
- (NSData*) dataFromSynchronous:(NSString*)httpMethod;
@end



@implementation WebClient
{
    NSURL* __url;
    NSString* __urlString;
    NSURLConnection* __urlConnection;
}


@synthesize baseURLString = __baseURLString;
@synthesize isUsed = __isUsed;
@synthesize serverTime = __serverTime;
@synthesize error = __error;
@synthesize processData = __processData;
@synthesize receivedData = __receivedData;


#pragma mark - Getters and Setters


- (NSURL*) url {
    if ( ! __url ) {
        __url = [NSURL
            URLWithString:self.urlString
            relativeToURL:[NSURL URLWithString:self.baseURLString]
        ];
    }
    return  __url;
}


- (void) setUrl:(NSURL*)url {
    __url = url;
    __urlString = nil;
}


- (NSString*) urlString {
    if ( ! __urlString ) {
        //  Must use __url here, not self.url, to avoid infinite trampolining
        //  when both __urlString and __url are nil.
        __urlString = [__url absoluteString];
    }
    return  __urlString;
}


- (void) setUrlString:(NSString*)urlString {
    __urlString = [urlString
        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding
    ];
    __url = nil;
}


- (NSMutableData*) receivedData {
    if ( !__receivedData) {
        self.receivedData = [NSMutableData dataWithCapacity:2048];
    }
    return __receivedData;
}


#pragma mark - Requesting the data


- (void) sendSynchronousHead {
    [self dataFromSynchronous:@"HEAD"];
}


- (void) sendSynchronousGet {
    [self processReceivedData:[self dataFromSynchronous:@"GET"]];
}


- (void) sendAsynchronousGet {
    if ( [self checkAndSetUsed] )  return;
    if ( ! [self isOKToSendRequest] )  return;

    //  Send off the asynchronous request now.
    __urlConnection = [NSURLConnection
        connectionWithRequest:[self requestWithMethod:@"GET"]
                     delegate:self
    ];
}


- (void) cancel {
    [__urlConnection cancel];
}


- (BOOL) isOKToSendRequest {
    //  Do nothing. This method is usually overriden by subclasses.
    return  YES;
}


- (void) processReceivedData:(NSData*)data {

    //  We process even if there is no data, since the client may need to know.
    if ( self.processData )  self.processData( data );

    if ( ! [data length] ) {
        //  data is nil (say, no response) or has no bytes. Log a warning.
        NSString* msg = [NSString
            stringWithFormat:@"WebClient received no data from %@", self.urlString
        ];
#ifdef DEBUG
        NSLog( @"*** %@", msg );
#endif
        self.error = [NSError
            errorWithDomain:WebClientErrorDomain
                       code:WebClientErrorNoDataInResponse
                   userInfo:[NSDictionary
                              dictionaryWithObject:msg
                                            forKey:NSLocalizedDescriptionKey
                            ]
        ];
    }
}


#pragma mark - NSURLConnection delegate methods


- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
    [self.receivedData appendData:data];
}


- (void)
            connection:(NSURLConnection*)connection
    didReceiveResponse:(NSHTTPURLResponse*)response
{
    self.serverTime = [response date];
}


- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
    [self processReceivedData:self.receivedData];
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


/** Makes a request with the given method ("GET", "POST", etc.) and a URL which
    is self.url. No cached response will be returned by the request.
*/
- (NSMutableURLRequest*) requestWithMethod:(NSString*)method {
    NSMutableURLRequest* request = [NSMutableURLRequest new];
    [request setURL:self.url];
    [request setHTTPMethod:method];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    return  request;
}


/** If the receiver's isUsed flag is YES, an assertion fails in DEBUG mode. In
    any case, the flag's value will be YES on return, but the returned BOOL will
    be its old value. Thus, since nothing else touches the flag, all subsequent
    calls result in the assertion failure and return YES.
*/
- (BOOL) checkAndSetUsed {
    BOOL wasUsed = self.isUsed;
    if ( wasUsed ) {
        NSAssert(
            NO,
            @"This WebClient instance has already been used. Create a new one."
        );
    } else {
        self.isUsed = YES;
    }
    return  wasUsed;
}


- (NSData*) dataFromSynchronous:(NSString*)httpMethod {
    if ( [self checkAndSetUsed] )  return nil;
    if ( ! [self isOKToSendRequest] )  return nil;

    NSHTTPURLResponse* response = nil;
    NSError* err = nil;

    NSData* data = [NSURLConnection
        sendSynchronousRequest:[self requestWithMethod:httpMethod]
             returningResponse:&response
                         error:&err
        ];
    self.error = err;
    self.serverTime = [response date];
    return  data;
}


@end
