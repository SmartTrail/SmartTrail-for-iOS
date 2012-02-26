//
//  BMATrailDescriptorWebClient.m
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMATrailDescriptorWebClient.h"
#import "BMANetworkUtilities.h"
#import "JSONKit.h"
#import "AppDelegate.h"

@interface BMATrailDescriptorWebClient ()
@property (readonly,nonatomic) PropConverter propConverterBlock;
- (void) closeConnection;
@end


@implementation BMATrailDescriptorWebClient


@synthesize eventNotificationDelegate;
@synthesize propConverterBlock = __propConverterBlock;


- (void) dealloc {
    [__propConverterBlock release];  __propConverterBlock = nil;
    [trailData release];
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


- (void) closeConnection {
    [urlConnection cancel];
    [urlConnection release];
    urlConnection = nil;
}


- (id) getTrailDescriptorForTrail : (NSInteger) trail
{
    [trailData release];

    trailData = [[NSMutableData alloc] init];

    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/trails/%d", trail];
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

- (void)
    notifyEventListenerOfTrailRetrievalCompletion:(BOOL)completionSuccessful
                                        withTrail:(Trail*)trail
{
    if(
        [[self eventNotificationDelegate]
            respondsToSelector:@selector(
                bmaTrailDescriptorWebClient:didCompleteTrailRetrieval:withTrail:
            )
        ]
    ) {
        [[self eventNotificationDelegate]
            bmaTrailDescriptorWebClient:self
              didCompleteTrailRetrieval:completionSuccessful
                              withTrail:trail];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"didFinishLoading");

    [self closeConnection];

    JSONDecoder *decoder = [JSONDecoder decoder];
    NSDictionary *responseData = [decoder objectWithData:trailData];
    NSDictionary *response = [responseData objectForKey:@"response"];
    NSArray *trails = [response objectForKey:@"trail"];
    NSDictionary *trailDictionary = [trails objectAtIndex:0];

    Trail* trail = (Trail*)[THE(dataUtils)
        updateOrInsertThe:@"trailForId"
           withProperties:self.propConverterBlock( trailDictionary )
    ];

    [self notifyEventListenerOfTrailRetrievalCompletion:YES withTrail:trail];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    [self notifyEventListenerOfTrailRetrievalCompletion:NO withTrail:nil];
    [self closeConnection];
}


@end
