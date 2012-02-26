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

@interface BMAAreaDescriptorsWebClient ()
@property (readonly,nonatomic) PropConverter propConverterBlock;
- (void) closeConnection;
@end


@implementation BMAAreaDescriptorsWebClient


@synthesize eventNotificationDelegate;
@synthesize propConverterBlock = __propConverterBlock;


- (void) dealloc
{
    [__propConverterBlock release];  __propConverterBlock = nil;
    [areaData release];
    [eventNotificationDelegate release];
    [self closeConnection];
    [super dealloc];
}


- (id) init {
    self = [super init];
    if ( self ) {
        __propConverterBlock = [[THE(dataUtils)
            dataDictToPropDictConverterForEntityName:@"Area"
                                usingFuncsByPropName:nil
            //  Note that when nil is provided for the dictionary of converter
            //  function blocks, each property will simply get the raw value in
            //  the data dictionary at the key equal to that property's name.

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

- (id) getAreaDescriptorsForRegion : (NSInteger) region
{
    [areaData release];

    areaData = [[NSMutableData alloc] init];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/regions/%d/areas",region];
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];

        [self closeConnection];

        urlConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    else
    {
        NSLog(@"No available network connections");
    }

    return self;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    [areaData appendData:data];
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

    [self closeConnection];

    JSONDecoder *decoder = [JSONDecoder decoder];
    NSDictionary *responseData = [decoder objectWithData:areaData];
    NSDictionary *response = [responseData objectForKey:@"response"];
    NSArray *areas = [response objectForKey:@"areas"];

    for ( NSDictionary *areaDictionary in areas ) {
        [THE(dataUtils)
            updateOrInsertThe:@"areaForId"
               withProperties:self.propConverterBlock( areaDictionary )
        ];
    }

    [self notifyEventListenerOfAreaRetrievalCompletion:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self notifyEventListenerOfAreaRetrievalCompletion:NO];
    [self closeConnection];
}

@end
