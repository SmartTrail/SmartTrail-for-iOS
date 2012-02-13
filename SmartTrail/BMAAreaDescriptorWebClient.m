//
//  BMAAreaDescriptorWebClient.m
//  SmartTrail
//
//  Created by John Dumais on 1/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMAAreaDescriptorWebClient.h"
#import "BMANetworkUtilities.h"
#import "JSONKit.h"
#import "BMAAreaDescriptor.h"

@implementation BMAAreaDescriptorWebClient

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

- (id) getAreaDescriptorForArea : (NSInteger) area
{
    if(areaData != nil)
    {
        [areaData release];
    }
    
    areaData = [[NSMutableData alloc] init];
    
    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSString *url = [NSString stringWithFormat:@"http://bouldermountainbike.org/trailsAPI/areas/%d", area];
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

- (void) notifyEventListenerOfAreaRetrievalCompletion : (BOOL) completionSuccessful withResultData : (BMAAreaDescriptor*) bmaAreaDescriptor
{
    if([[self eventNotificationDelegate] respondsToSelector:@selector(bmaAreaDescriptorWebClient:didCompleteAreaRetrieval:withAreaDescriptor:)])
    {
        [[self eventNotificationDelegate] bmaAreaDescriptorWebClient:self didCompleteAreaRetrieval:completionSuccessful withAreaDescriptor:bmaAreaDescriptor];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{ 
    NSLog(@"didFinishLoading");
    
    [self closeConnection];

    JSONDecoder *decoder = [JSONDecoder decoder];
    NSDictionary *responseData = [decoder objectWithData:areaData];
    NSDictionary *response = [responseData objectForKey:@"response"];
    NSArray *area = [response objectForKey:@"area"];
    NSDictionary *areaDictionary = [area objectAtIndex:0];
    BMAAreaDescriptor *areaDescriptor = [[[BMAAreaDescriptor alloc] init] autorelease];
    [areaDescriptor setId:[[areaDictionary objectForKey:@"id"] intValue]];
    [areaDescriptor setAreaName:[areaDictionary objectForKey:@"name"]];
    
    [self notifyEventListenerOfAreaRetrievalCompletion:YES withResultData:areaDescriptor];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
    NSLog(@"%@", error);
    [self notifyEventListenerOfAreaRetrievalCompletion:NO withResultData:nil];
    [self closeConnection];
}    

@end
