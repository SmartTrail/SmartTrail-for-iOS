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
#import APP_DELEGATE_H

@implementation BMATrailsDescriptorWebClient

@synthesize eventNotificationDelegate;

- (void) closeConnection
{
    [urlConnection cancel];
    [urlConnection release];
    urlConnection = nil;
}

- (void) dealloc
{
    [trailData release];
    [eventNotificationDelegate release];
    [self closeConnection];
    [super dealloc];
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

    //  TODO: The following transformation of trails to Trail managed objects
    //  needs to be abstracted into a utility.
    //  Note that area and descriptionPartial are handled specially below.

    NSSet* keysOfStrings = [NSSet
        setWithObjects:@"descriptionFull", @"name", @"url", nil
    ];
    NSSet* keysOfInts = [NSSet
        setWithObjects:@"aerobicRating", @"condition", @"coolRating",
                       @"elevationGain", @"techRating",
                       nil
    ];
    NSSet* keysOfFloats = [NSSet setWithObjects:@"length", nil];
    NSSet* keysOfDates = [NSSet setWithObjects:@"updatedAt", nil];

    NSMutableDictionary* dict = [NSMutableDictionary new];

    for ( NSDictionary *trailDictionary in trails ) {
        [dict removeAllObjects];

        [trailDictionary
            enumerateKeysAndObjectsUsingBlock:^(id key, NSString* val, BOOL* stop) {
                if ( [keysOfStrings containsObject:key] ) {
                    [dict setObject:val forKey:key];
                } else if ( [keysOfInts containsObject:key] ) {
                    [dict
                        setObject:[NSNumber numberWithInt:[val intValue]]
                           forKey:key
                    ];
                } else if ( [keysOfFloats containsObject:key] ) {
                    [dict
                        setObject:[NSNumber numberWithFloat:[val floatValue]]
                           forKey:key
                    ];
                } else if ( [keysOfDates containsObject:key] ) {
                    [dict
                        setObject:[NSDate dateWithTimeIntervalSince1970:[
                                      [trailDictionary
                                          objectForKey:key
                                      ] doubleValue
                                  ]]
                           forKey:key
                    ];
                }
            }
        ];

        //  Use key "descriptionPartial" instead of "description". The former
        //  conflicts with NSObjects -description method.
        //
        [dict
            setObject:[trailDictionary objectForKey:@"description"]
               forKey:@"descriptionPartial"
        ];

        //  Area is a relationship and must be populated.
        //
        {   NSManagedObject* areaObj;
            ERR_ASSERT(
                areaObj = [THE(dataUtils)
                    findThe:@"areaForId"
                         at:[trailDictionary objectForKey:@"area"]
                      error:&ERR
                ];
            );
            if ( areaObj ) [dict setObject:areaObj forKey:@"area"];
        }

        //  Create or update the Trail managed object.
        //
        {   NSString* idStr = [trailDictionary objectForKey:@"id"];
            if ( idStr ) {
                ERR_ASSERT(
                    [THE(dataUtils)
                        updateOrInsertThe:@"trailForId"
                                       at:idStr
                           withAttributes:dict
                                    error:&ERR
                    ]
                );
            }
        }

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

    [dict release];
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
