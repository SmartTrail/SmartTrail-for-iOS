//
//  BMAConditionsDescriptorWebClient.m
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAConditionsDescriptorWebClient.h"
#import "BMANetworkUtilities.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "NSHTTPURLResponse+Utils.h"

@interface BMAConditionsDescriptorWebClient ()
@property (readonly,nonatomic) PropConverter    propConverterBlock;
@property (retain,nonatomic)   NSURLConnection* urlConnection;
@property (retain,nonatomic)   NSMutableData*   receivedJSON;
@property (retain,nonatomic)   NSDate*          serverTime;
@end


@implementation BMAConditionsDescriptorWebClient


@synthesize eventNotificationDelegate = __eventNotificationDelegate;
@synthesize propConverterBlock = __propConverterBlock;
@synthesize urlConnection = __urlConnection;
@synthesize receivedJSON = __receivedJSON;
@synthesize serverTime = __serverTime;


- (void) dealloc
{
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
            dataDictToPropDictConverterForEntityName:@"Condition"
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:

                    //  This calculation using               goes into property
                    //    the data dictionary                  having this name.

                    fnStringForDataKey(@"nickname"),         @"authorName",
                    fnIntegerForDataKey(@"conditionId"),     @"rating",
                    fnDateSince1970ForDataKey(@"updatedAt"), @"updatedAt",

                    //  When this dictionary is handed to CoreDataUtil's
                    //  updateOrInsertThe:withProperties: method, serverTime
                    //  will contain the response's Date. So just report it.
                    //
                    [[^(id _1, id _2) {
                        return  self.serverTime;
                    } copy] autorelease],                    @"downloadedAt",

                    //  All that remains is to populate the "trail" relationship.
                    //  For this to work, The Trail entities must already have
                    //  been loaded.
                    //
                    [[^( NSDictionary* dataDict, id _ ){
                        return  [THE(dataUtils)
                            findThe:@"trailForId"
                                 at:[dataDict objectForKey:@"trailId"]
                        ];
                    } copy] autorelease],                    @"trail",

                    fnCoerceDataKey(nil),                    AnyOtherProperty,

                    nil                              ]
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


- (id) getTrailConditionsForTrail:(NSInteger)trail
{
    self.receivedJSON = [[NSMutableData new] autorelease];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/trails/%d/conditions", trail];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

        self.urlConnection = [[[NSURLConnection alloc]
            initWithRequest:request delegate:self startImmediately:YES
        ] autorelease];
    }
    else
    {
        NSLog(@"No network available");
    }

    return self;
}


- (id) getTrailConditionsForArea:(NSInteger)area
{
    self.receivedJSON = [[NSMutableData new] autorelease];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/areas/%d/conditions", area];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

        self.urlConnection = [[[NSURLConnection alloc]
            initWithRequest:request delegate:self startImmediately:YES
        ] autorelease];
    }
    else
    {
        NSLog(@"No network available");
    }

    return self;
}


- (id) getTrailConditionsForRegion : (NSInteger) region
{

    self.receivedJSON = [[NSMutableData new] autorelease];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/regions/%d/conditions", region];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

        self.urlConnection = [[[NSURLConnection alloc]
            initWithRequest:request delegate:self startImmediately:YES
        ] autorelease];
    }
    else
    {
        NSLog(@"No network available");
    }

    return self;
}


- (void)
            connection:(NSURLConnection*)connection
    didReceiveResponse:(NSHTTPURLResponse*)response
{
    self.serverTime = [response date];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    NSLog(@"didReceiveData");
    [self.receivedJSON appendData:data];
}


- (void) notifyEventListenerOfConditionRetrievalCompletion:(BOOL)completionSuccessful
{
    if(
        [[self eventNotificationDelegate]
            respondsToSelector:@selector(
                bmaTrailConditionsWebClient:didCompleteConditionRetrieval:
            )
        ]
    ) {
        [[self eventNotificationDelegate]
              bmaTrailConditionsWebClient:self
            didCompleteConditionRetrieval:completionSuccessful
        ];
    }
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"didFinishLoading");

    JSONDecoder *decoder = [JSONDecoder decoder];
    NSDictionary *responseData = [decoder objectWithData:self.receivedJSON];
    NSDictionary *response = [responseData objectForKey:@"response"];
    NSArray *dataDictArray = [response objectForKey:@"conditions"];

    for ( NSDictionary* dataDict in dataDictArray ) {
        //  Create or update a Condition managed object loaded with data from
        //  conditionDictionary.

        [THE(dataUtils)
            updateOrInsertThe:@"conditionForId"
               withProperties:self.propConverterBlock( dataDict )
        ];
    }

    [self notifyEventListenerOfConditionRetrievalCompletion:YES];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self notifyEventListenerOfConditionRetrievalCompletion:NO];
    self.urlConnection = nil;
}


@end
