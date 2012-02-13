//
//  BMATrailDescriptorWebClient.m
//  SmartTrail
//
//  Created by John Dumais on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BMATrailDescriptorWebClient.h"
#import "BMATrailDescriptor.h"
#import "BMANetworkUtilities.h"
#import "JSONKit.h"

@implementation BMATrailDescriptorWebClient

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

- (void) notifyEventListenerOfTrailRetrievalCompletion : (BOOL) completionSuccessful withTrailDescriptor : (BMATrailDescriptor*) trailDescriptor
{
    if([[self eventNotificationDelegate] respondsToSelector:@selector(bmaTrailDescriptorWebClient:didCompleteTrailRetrieval:withTrailDescriptor:)])
    {
        [[self eventNotificationDelegate] bmaTrailDescriptorWebClient:self didCompleteTrailRetrieval:completionSuccessful withTrailDescriptor:trailDescriptor];
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
    BMATrailDescriptor *trailDescriptor = [[[BMATrailDescriptor alloc] init] autorelease];
    
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
    
    [self notifyEventListenerOfTrailRetrievalCompletion:YES withTrailDescriptor:trailDescriptor];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
    NSLog(@"%@", error);
    [self notifyEventListenerOfTrailRetrievalCompletion:NO withTrailDescriptor:nil];
    [self closeConnection];
}    


@end
