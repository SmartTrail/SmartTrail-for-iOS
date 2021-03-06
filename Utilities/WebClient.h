//
//  Created by tyler on 2012-03-30.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <Foundation/Foundation.h>

static NSString* const WebClientErrorDomain = @"WebClientErrorDomain";
enum { WebClientErrorNoDataInResponse };
typedef void(^ReceivedDataProcessor)(NSData*);

/** This class is responsible for issuing a request to an HTTP server, loading
    the returned data, and optionally processing the data. This sequence may be
    conducted synchronously or asynchronously, but can be done only once. That
    is, an instance has a lifetime consisting of only one request-load-update
    sequence, then it is finished and cannot be reused. This simplifies
    asynchronous processes, since each instance is associated with just one such
    sequence.
*/
@interface WebClient : NSObject

/** The complete URL for the request. Assign to the url or urlString property
    before calling a "send..." method. Properties url and urlString keep
    themselves current when the other is changed. If urlString is just a file
    path, then you must set property baseURLString to indicate the base URL.
    Assigning to urlString actually stores a percent-escaped version of the
    given string.
*/
@property (strong,nonatomic)            NSURL*                  url;
@property (copy,nonatomic)              NSString*               urlString;
@property (copy,nonatomic)              NSString*               baseURLString;

/** Has value YES iff a "send..." method has been called.
*/
@property (readonly,assign,nonatomic)   BOOL                    isUsed;

/** The time found in the response to the request initiated by a "send..."
    method.
*/
@property (readonly,strong,nonatomic)
                                        NSDate*                 serverTime;

/** If the request initiated by a "send..." is unsuccessful, an error is stored
    in this property. Otherwise it is nil.
*/
@property (readonly,strong,nonatomic)   NSError*                error;

/** Called by method processReceivedData, which is called when all data has
    been received from the server. The data is provided to its single NSData*
    argument. Need not be assigned.
*/
@property (copy,nonatomic)              ReceivedDataProcessor    processData;

/** Sends a HEAD request to the URL defined by property urlString. This method
    does not return until a response is obtained. Once this method is called,
    the receiver is considered used (property isUsed is YES), and neither method
    sendSynchronousGet nor sendAsynchronousGet will function again. Since the
    response to a HEAD request has no body, this is useful to "ping" the server,
    perhaps to obtain the date/time according to the server (see property
    serverTime).
*/
- (void) sendSynchronousHead;

/** Sends a GET request to the URL defined by property urlString. This method
    does not return until the resulting data is loaded and processed into
    managed objects. Once this method is called, the receiver is considered used
    (property isUsed is YES), and neither method sendSynchronousGet nor
    sendAsynchronousGet will function again.
*/
- (void) sendSynchronousGet;

/** Sends a GET request to the URL defined by property urlString. Returns
    immediately without waiting for the response. Once this method is called,
    the receiver is considered used (property isUsed is YES), and neither method
    sendSynchronousGet nor sendAsynchronousGet will function again.
*/
- (void) sendAsynchronousGet;

/** If sendAsynchronousGet was called, but response data has not yet begun to
    be processed, this method may be called to ignore any response data.
*/
- (void) cancel;

/** Called just before a request is sent, an implementing subclass can override
    to, for example, check for the integrity of properties used by the subclass'
    implementation of processData.
*/
- (BOOL) isOKToSendRequest;

/** Processes the given data. Often overridden by subclasses, this method
    only logs a warning if the argument is nil and if we're running in DEBUG
    mode. Otherwise, it calls block self.processData if it is not nil.
*/
- (void) processReceivedData:(NSData*)data;

@end
