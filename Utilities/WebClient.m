//
//  Created by tyler on 2012-03-30.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "WebClient.h"
#import "NSHTTPURLResponse+Utils.h"


@interface WebClient ()
@property (readwrite,assign,nonatomic)  BOOL            isUsed;
@property (readwrite,nonatomic)         NSDate*         serverTime;
@property (readwrite,nonatomic)         NSError*        error;
@property (nonatomic)                   NSMutableData*  receivedData;
- (BOOL) checkAndSetUsed;
- (NSData*) dataFromSynchronous:(NSString*)httpMethod;
@end

NSMutableURLRequest* makeRequest( NSString* method, NSString* urlString );


@implementation WebClient
{
    NSURLConnection* __urlConnection;
}


@synthesize urlString = __urlString;
@synthesize isUsed = __isUsed;
@synthesize serverTime = __serverTime;
@synthesize error = __error;
@synthesize receivedData = __receivedData;


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
        connectionWithRequest:makeRequest( @"GET", self.urlString )
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
    if ( ! data ) {
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


/** Makes an autoreleased "GET" request with a URL from the given string.
*/
NSMutableURLRequest* makeRequest( NSString* method, NSString* urlString ) {
    NSMutableURLRequest* request = [NSMutableURLRequest new];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:method];
    return  request;
}


/** Getter for private property receivedData that initializes it on first call.
*/
- (NSMutableData*) receivedData {
    if ( !__receivedData) {
        self.receivedData = [NSMutableData dataWithCapacity:2048];
    }
    return __receivedData;
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
        sendSynchronousRequest:makeRequest( httpMethod, self.urlString )
             returningResponse:&response
                         error:&err
    ];
    self.error = err;
    self.serverTime = [response date];
    return  data;
}


@end
