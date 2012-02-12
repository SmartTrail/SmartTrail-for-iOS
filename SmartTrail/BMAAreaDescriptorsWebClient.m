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
#import "BMAAreaDescriptor.h"

@implementation BMAAreaDescriptorsWebClient

@synthesize eventNotificationDelegate;

- (void) closeConnection
{
    [urlConnection cancel];
    [urlConnection release];
    urlConnection = nil;
}

- (void) dealloc
{
    [areaData release];
    [eventNotificationDelegate release];
    [self closeConnection];
    [super dealloc];
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

- (void) notifyEventListenerOfAreaRetrievalCompletion : (BOOL) completionSuccessful withResultData : (NSArray*) resultData
{
    if([[self eventNotificationDelegate] respondsToSelector:@selector(bmaAreaDescriptorsWebClient:didCompleteAreaRetrieval:withResultArray:)])
    {
        [[self eventNotificationDelegate] bmaAreaDescriptorsWebClient:self didCompleteAreaRetrieval:completionSuccessful withResultArray:resultData];
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
    
    NSMutableArray *resultArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *areaDictionary in areas)
    {
        BMAAreaDescriptor *areaDescriptor = [[BMAAreaDescriptor alloc] init];
        [areaDescriptor setId:[[areaDictionary objectForKey:@"id"] intValue]];
        [areaDescriptor setAreaName:[areaDictionary objectForKey:@"name"]];
        [resultArray addObject:areaDescriptor];
        [areaDescriptor release];
    }
    
    [self notifyEventListenerOfAreaRetrievalCompletion:YES withResultData:resultArray];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
    NSLog(@"%@", error);
    [self notifyEventListenerOfAreaRetrievalCompletion:NO withResultData:nil];
    [self closeConnection];
}    

@end
