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

@interface BMAConditionsDescriptorWebClient ()
@property (readonly,nonatomic) PropConverter propConverterBlock;
- (void) closeConnection;
@end


@implementation BMAConditionsDescriptorWebClient

@synthesize eventNotificationDelegate;
@synthesize propConverterBlock = __propConverterBlock;


- (void) dealloc
{
    [__propConverterBlock release];  __propConverterBlock = nil;
    [conditionData release];
    [eventNotificationDelegate release];
    [self closeConnection];
    [super dealloc];
}


- (id) init {
    self = [super init];
    if ( self ) {
        __propConverterBlock = [[THE(dataUtils)
            dataDictToPropDictConverterForEntityName:@"Trail"
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:

                    //  This calculation using               goes into property
                    //    the data dictionary                  having this name.

                    fnIntForDataKey(@"rating"),              @"conditionId",
                    fnDateSince1970ForDataKey(@"updatedAt"), @"updatedAt",

                    //  Note that data for each remaining property key, by
                    //  default, is looked up in the data dictionary at that
                    //  key.

                    nil                              ]
        ] retain];
    }
    return  self;
}


- (void) closeConnection
{
    [urlConnection cancel];
    [urlConnection release];
    urlConnection = nil;
}


- (id) getTrailConditionsForTrail:(NSInteger)trail
{
    [conditionData release];

    conditionData = [[NSMutableData alloc] init];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/trails/%d/conditions", trail];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

        [self closeConnection];

        urlConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    else
    {
        NSLog(@"No network available");
    }

    return self;
}

- (id) getTrailConditionsForArea:(NSInteger)area
{
    [conditionData release];

    conditionData = [[NSMutableData alloc] init];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/areas/%d/conditions", area];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

        [self closeConnection];

        urlConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    else
    {
        NSLog(@"No network available");
    }

    return self;
}

- (id) getTrailConditionsForRegion : (NSInteger) region
{

    [conditionData release];

    conditionData = [[NSMutableData alloc] init];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/regions/%d/conditions", region];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

        [self closeConnection];

        urlConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    else
    {
        NSLog(@"No network available");
    }

    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    [conditionData appendData:data];
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

    [self closeConnection];

    JSONDecoder *decoder = [JSONDecoder decoder];
    NSDictionary *responseData = [decoder objectWithData:conditionData];
    NSDictionary *response = [responseData objectForKey:@"response"];
    NSArray *conditions = [response objectForKey:@"conditions"];

    for (NSDictionary *conditionDictionary in conditions)
    {
        //  Create or update a Condition managed object loaded with data from
        //  conditionDictionary.

        [THE(dataUtils)
            updateOrInsertThe:@"conditionForId"
               withProperties:self.propConverterBlock(conditionDictionary)
        ];
    }

    [self notifyEventListenerOfConditionRetrievalCompletion:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self notifyEventListenerOfConditionRetrievalCompletion:NO];
    [self closeConnection];
}

@end
