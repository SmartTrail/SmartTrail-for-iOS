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
#import "BMAConditionDescriptor.h"

@implementation BMAConditionsDescriptorWebClient

@synthesize eventNotificationDelegate;

- (void) closeConnection
{
    [urlConnection cancel];
    [urlConnection release];
    urlConnection = nil;
}

- (void) dealloc
{
    [conditionData release];
    [eventNotificationDelegate release];
    [self closeConnection];
    [super dealloc];
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

- (void) notifyEventListenerOfConditionRetrievalCompletion : (BOOL) completionSuccessful withResultData : (NSArray*) resultData
{
    if([[self eventNotificationDelegate] respondsToSelector:@selector(bmaTrailConditionsWebClient:didCompleteConditionRetrieval:withResultArray:)])
    {
        [[self eventNotificationDelegate] bmaTrailConditionsWebClient:self didCompleteConditionRetrieval:completionSuccessful withResultArray:resultData];
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
    
    NSMutableArray *resultArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSDictionary *trailDictionary in conditions)
    {
        BMAConditionDescriptor *conditionDescriptor = [[BMAConditionDescriptor alloc] init];
        [conditionDescriptor setArea:[[trailDictionary objectForKey:@"area"] intValue]];
        [conditionDescriptor setComment:[trailDictionary objectForKey:@"comment"]];
        [conditionDescriptor setCommentId:[[trailDictionary objectForKey:@"id"] intValue]];
        [conditionDescriptor setCondition:[trailDictionary objectForKey:@"condition"]];
        [conditionDescriptor setConditionId:[[trailDictionary objectForKey:@"conditionId"] intValue]];
        [conditionDescriptor setLastUpdated:[NSDate dateWithTimeIntervalSince1970:[[trailDictionary objectForKey:@"updatedAt"] doubleValue]]];
        [conditionDescriptor setNickName:[trailDictionary objectForKey:@"nickname"]];
        [conditionDescriptor setTrailId:[[trailDictionary objectForKey:@"trailId"] intValue]];
        [conditionDescriptor setUserId:[[trailDictionary objectForKey:@"userId"] intValue]];
        
        [resultArray addObject:conditionDescriptor];
        [conditionDescriptor release];
    }
    
    [self notifyEventListenerOfConditionRetrievalCompletion:YES withResultData:resultArray];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
    NSLog(@"%@", error);
    [self notifyEventListenerOfConditionRetrievalCompletion:NO withResultData:nil];
    [self closeConnection];
}    

@end
