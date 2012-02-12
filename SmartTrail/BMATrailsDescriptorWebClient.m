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

- (id) getTrailsDescriptorForArea : (NSInteger) area
{
    [trailData release];
    
    trailData = [[NSMutableData alloc] init];
    
    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/areas/%d/trails",area];
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
    
    for (NSDictionary *trailDictionary in trails)
    {
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
        
        NSLog(@"%@", trailDescriptor);
        [trailDescriptor release];
    }
    
    [self notifyEventListenerOfTrailsRetrievalCompletion:YES withResultData:resultArray];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
    NSLog(@"%@", error);
    [self notifyEventListenerOfTrailsRetrievalCompletion:NO withResultData:nil];
    [self closeConnection];
}    

@end
