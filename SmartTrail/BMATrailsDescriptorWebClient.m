//
//  BMATrailsDescriptorWebClient.m
//  SmartTrail
//
//  Created by John Dumais on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMATrailsDescriptorWebClient.h"
#import "BMANetworkUtilities.h"
#import "BMATrailDescriptor.h"
#import "JSONKit.h"
#import "AppDelegate.h"

@interface BMATrailsDescriptorWebClient ()
@property (readonly,nonatomic) PropConverter converterFunc;
- (void) closeConnection;
@end


@implementation BMATrailsDescriptorWebClient


@synthesize eventNotificationDelegate;
@synthesize converterFunc = __converterFunc;


- (void) dealloc
{
    [trailData release];
    [eventNotificationDelegate release];
    [self closeConnection];
    [super dealloc];
}


- (id) init {
    self = [super init];
    if ( self ) {
        __converterFunc = [[THE(dataUtils)
            dataDictToPropDictConverterForEntityName:@"Trail"
                                usingFuncsByPropName:[NSDictionary
                dictionaryWithObjectsAndKeys:

                    //  This calculation using               goes into property
                    //    the data dictionary                  having this name.

                    fnIntForDataKey(@"aerobicRating"),       @"aerobicRating",
                    fnIntForDataKey(@"condition"),           @"condition",
                    fnIntForDataKey(@"coolRating"),          @"coolRating",
                    fnRawForDataKey(@"description"),         @"descriptionPartial",
                    fnIntForDataKey(@"elevationGain"),       @"elevationGain",
                    fnFloatForDataKey(@"length"),            @"length",
                    fnIntForDataKey(@"techRating"),          @"techRating",
                    fnDateSince1970ForDataKey(@"updatedAt"), @"updatedAt",

                    //  Note that data for each remaining property key, by
                    //  default, is looked up in the data dictionary at that
                    //  key.

                    //  All that remains is to populate the "area" relationship.
                    //  For this to work, The Area entities must already have
                    //  been loaded.
                    //
                    [[^( NSDictionary* dataDict, id _ ){
                        return  [THE(dataUtils)
                            findThe:@"areaForId"
                                 at:[dataDict objectForKey:@"area"]
                        ];
                    } copy] autorelease],                    @"area",

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


- (id) getTrailsDescriptorForRegion : (NSInteger) region
{
    [trailData release];

    trailData = [[NSMutableData alloc] init];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/regions/%d/trails", region];
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

- (id) getTrailsDescriptorForArea : (NSInteger) area
{
    [trailData release];

    trailData = [[NSMutableData alloc] init];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/areas/%d/trails", area];
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
    [trailData appendData:data];
}

- (void) notifyEventListenerOfTrailsRetrievalCompletion : (BOOL) completionSuccessful withResultData : (NSArray*) resultData
{
    if([[self eventNotificationDelegate] respondsToSelector:@selector(bmaTrailDescriptorsWebClient:didCompleteTrailRetrieval:withResultArray:)])
    {
        [[self eventNotificationDelegate] bmaTrailDescriptorsWebClient:self didCompleteTrailRetrieval:completionSuccessful withResultArray:resultData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"didFinishLoading");

    [self closeConnection];

    JSONDecoder *decoder = [JSONDecoder decoder];
    NSDictionary *responseData = [decoder objectWithData:trailData];
    NSDictionary *response = [responseData objectForKey:@"response"];
    NSArray *trails = [response objectForKey:@"trails"];

    NSMutableArray *resultArray = [[[NSMutableArray alloc] init] autorelease];

    for ( NSDictionary *trailDictionary in trails ) {

        //  Create or update the Trail managed object.
        //
        [THE(dataUtils)
            updateOrInsertThe:@"trailForId"
               withProperties:self.converterFunc(trailDictionary)
        ];

        BMATrailDescriptor *trailDescriptor = [[BMATrailDescriptor alloc] init];
        [trailDescriptor setAerobicRating:[[trailDictionary objectForKey:@"aerobicRating"] intValue]];
        [trailDescriptor setArea:[[trailDictionary objectForKey:@"area"] intValue]];
        [trailDescriptor setCondition:[[trailDictionary objectForKey:@"condition"] intValue]];
        [trailDescriptor setCoolRating:[[trailDictionary objectForKey:@"coolRating"] intValue]];
        [trailDescriptor setDescription:[trailDictionary objectForKey:@"description"]];
        [trailDescriptor setElevationGain:[[trailDictionary objectForKey:@"elevationGain"] intValue]];
        [trailDescriptor setFullDescription:[trailDictionary objectForKey:@"descriptionFull"]];
        [trailDescriptor setLastUpdated:[NSDate dateWithTimeIntervalSince1970:[[trailDictionary objectForKey:@"updatedAt"] doubleValue]]];
        [trailDescriptor setLength:[[trailDictionary objectForKey:@"length"] floatValue]];
        [trailDescriptor setName:[trailDictionary objectForKey:@"name"]];
        [trailDescriptor setTechRating:[[trailDictionary objectForKey:@"techRating"] intValue]];
        [trailDescriptor setTrailId:[[trailDictionary objectForKey:@"id"] intValue]];
        [trailDescriptor setUrl:[trailDictionary objectForKey:@"url"]];

        [resultArray addObject:trailDescriptor];
        [trailDescriptor release];
    }

    [APP_DELEGATE saveContext];

    [self notifyEventListenerOfTrailsRetrievalCompletion:YES withResultData:resultArray];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self notifyEventListenerOfTrailsRetrievalCompletion:NO withResultData:nil];
    [self closeConnection];
}

@end
