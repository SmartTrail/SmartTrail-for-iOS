//
//  BMAAreaDescriptorWebClient.m
//  SmartTrail
//
//  Created by John Dumais on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAAreaDescriptorsWebClient.h"
#import "BMANetworkUtilities.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "NSHTTPURLResponse+Utils.h"

@interface BMAAreaDescriptorsWebClient ()
@property (readonly,nonatomic) PropConverter    propConverterBlock;
@property (retain,nonatomic)   NSURLConnection* urlConnection;
@property (retain,nonatomic)   NSMutableData*   receivedJSON;
@property (retain,nonatomic)   NSDate*          serverTime;
@end


@implementation BMAAreaDescriptorsWebClient


@synthesize eventNotificationDelegate = __eventNotificationDelegate;
@synthesize propConverterBlock = __propConverterBlock;
@synthesize urlConnection = __urlConnection;
@synthesize receivedJSON = __receivedJSON;
@synthesize serverTime = __serverTime;


- (void) dealloc {
    [__eventNotificationDelegate release];  __eventNotificationDelegate = nil;
    [__propConverterBlock release];         __propConverterBlock = nil;
    [__urlConnection release];              __urlConnection = nil;
    [__receivedJSON release];               __receivedJSON = nil;
    [__serverTime release];                 __serverTime = nil;
    [super dealloc];
}


- (id) init {
    self = [super init];
    if ( self ) {
        __propConverterBlock = [[THE(dataUtils)
            dataDictToPropDictConverterForEntityName:@"Area"
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:

                    //  This calculation using               goes into property
                    //    the data dictionary                  having this name.

                    //  When this dictionary is handed to CoreDataUtil's
                    //  updateOrInsertThe:withProperties: method, serverTime
                    //  will contain the response's Date. So just report it.
                    //
                    [[^(id _1, id _2) {
                        return  self.serverTime;
                    } copy] autorelease],                    @"downloadedAt",

                    //  This guards against the possibility that a data value
                    //  has the wrong type.
                    //
                    fnCoerceDataKey(nil),                    AnyOtherProperty,

                    nil
                ]
        ] retain];
    }
    return  self;
}


- (void) setUrlConnection:(NSURLConnection*)anUrlConnection {
    [__urlConnection cancel];
    [__urlConnection release];
    __urlConnection = anUrlConnection;
    [__urlConnection retain];
}


- (id) getAreaDescriptorsForRegion : (NSInteger) region
{
    self.receivedJSON = [[NSMutableData new] autorelease];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/regions/%d/areas",region];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

        self.urlConnection = [[[NSURLConnection alloc]
            initWithRequest:request delegate:self startImmediately:YES
        ] autorelease];
    }
    else
    {
        NSLog(@"No available network connections");
    }

    return self;
}


- (void)
            connection:(NSURLConnection*)connection
    didReceiveResponse:(NSHTTPURLResponse*)response
{
    self.serverTime = [response date];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    [self.receivedJSON appendData:data];
}


- (void) notifyEventListenerOfAreaRetrievalCompletion:(BOOL)completionSuccessful
{
    if([[self eventNotificationDelegate] respondsToSelector:@selector(bmaAreaDescriptorsWebClient:didCompleteAreaRetrieval:)])
    {
        [[self eventNotificationDelegate] bmaAreaDescriptorsWebClient:self didCompleteAreaRetrieval:completionSuccessful];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"didFinishLoading");

    JSONDecoder *decoder = [JSONDecoder decoder];
    NSDictionary *responseData = [decoder objectWithData:self.receivedJSON];
    NSDictionary *response = [responseData objectForKey:@"response"];
    NSArray *dataDictArray = [response objectForKey:@"areas"];

    for ( NSDictionary* dataDict in dataDictArray ) {
        [THE(dataUtils)
            updateOrInsertThe:@"areaForId"
               withProperties:self.propConverterBlock( dataDict )
        ];
    }

    [self notifyEventListenerOfAreaRetrievalCompletion:YES];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self notifyEventListenerOfAreaRetrievalCompletion:NO];
    self.urlConnection = nil;
}


@end
