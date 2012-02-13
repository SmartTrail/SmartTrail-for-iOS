//
//  BMAEventsDescriptorWebClient.m
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAEventsDescriptorWebClient.h"
#import "BMANetworkUtilities.h"
#import "JSONKit.h"
#import "BMAEventDescriptor.h"

@implementation BMAEventsDescriptorWebClient

@synthesize eventNotificationDelegate;

- (void) closeConnection
{
    [urlConnection cancel];
    [urlConnection release];
    urlConnection = nil;
}

- (void) dealloc
{
    [eventNotificationDelegate release];
    [eventData release];
    [self closeConnection];
    [super dealloc];
}

- (id) getEventsForRegion : (NSUInteger) region
{
    [eventData release];
    
    eventData = [[NSMutableData alloc] init];
    
    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/regions/%d/events", region];
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
    [eventData appendData:data];
} 

- (void) notifyEventListenerOfEventRetrievalCompletion : (BOOL) completionSuccessful withResultData : (NSArray*) resultData
{
    if([[self eventNotificationDelegate] respondsToSelector:@selector(bmaEventsDescriptionWebClient:didCompleteEventRetrieval:withResultArray:)])
    {
        [[self eventNotificationDelegate] bmaEventsDescriptionWebClient:self didCompleteEventRetrieval:completionSuccessful withResultArray:resultData];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{ 
    NSLog(@"didFinishLoading");
    
    [self closeConnection];
    
    JSONDecoder *decoder = [JSONDecoder decoder];
    NSDictionary *responseData = [decoder objectWithData:eventData];
    NSDictionary *response = [responseData objectForKey:@"response"];
    NSArray *events = [response objectForKey:@"events"];
    
    NSMutableArray *resultArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *eventDictionary in events)
    {
        BMAEventDescriptor *eventDescriptor = [[BMAEventDescriptor alloc] init];
        [eventDescriptor setName:[eventDictionary objectForKey:@"name"]];
        [eventDescriptor setEventId:[[eventDictionary objectForKey:@"id"]intValue]];
        [eventDescriptor setLastUpdated:[NSDate dateWithTimeIntervalSince1970:[[eventDictionary objectForKey:@"updatedAt"] doubleValue]]];
        [eventDescriptor setName:[eventDictionary objectForKey:@"name"]];
        [eventDescriptor setUrl:[eventDictionary objectForKey:@"url"]];
        [eventDescriptor setEventDescription:[eventDictionary objectForKey:@"description"]];
        
        [resultArray addObject:eventDescriptor];
        [eventDescriptor release];
    }
    
    [self notifyEventListenerOfEventRetrievalCompletion:YES withResultData:resultArray];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
    NSLog(@"%@", error);
    [self notifyEventListenerOfEventRetrievalCompletion:NO withResultData:nil];
    [self closeConnection];
}

@end
