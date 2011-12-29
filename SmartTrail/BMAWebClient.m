//
//  BMAWebClient.m
//  SmartTrail
//
//  Created by John Dumais on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BMAWebClient.h"
#import "BMANetworkUtilities.h"

@implementation BMAWebClient

@synthesize sessionCookie;

- (void) closeConnection
{
    [urlConnection cancel];
    [urlConnection release];
    urlConnection = nil;
}

- (id) init
{
    self = [super init];
    
    if(self)
    {
        eventListeners = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [sessionCookie release];
    [sessionUserName release];
    [sessionPassword release];
    [self closeConnection];
    [eventListeners release];
    
    [super dealloc];
}

- (void) logIntoBmaWebSiteAsync : (NSString*) withUserName andPassword : (NSString*) passWord
{
    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        [sessionPassword release];
        [sessionPassword initWithString:passWord];
        
        [sessionUserName release];
        [sessionUserName initWithString:sessionUserName];
        
        NSString *credentials = [NSString stringWithFormat:@"username=%@&password=%@", withUserName, passWord];
        NSData *dataToBePostedToWebService = [credentials dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [dataToBePostedToWebService length]];  
        
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:@"https://bouldermountainbike.org/user"]];  
        [request setHTTPMethod:@"POST"];  
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];  
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];  
        [request setHTTPBody:dataToBePostedToWebService];  

        [self closeConnection];
        
        urlConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    else
    {
        NSLog(@"No available network connections");
    }
}

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    //return YES to say that we have the necessary credentials to access the requested resource
    return YES;
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge previousFailureCount] == 0)
    {
        NSURLCredential *newCredential;
        newCredential = [NSURLCredential credentialWithUser:sessionUserName
                                                   password:sessionPassword
                                                persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
    }
    else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        // inform the user that the user name and password
        // in the preferences are incorrect
        NSLog(@"Bad credentials");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    NSDictionary *fields = [HTTPResponse allHeaderFields];
    NSLog(@"%@", fields);
    NSLog(@"%d", [HTTPResponse statusCode]);
    [sessionCookie release];
    [sessionCookie initWithString:[fields valueForKey:@"Set-Cookie"]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{ 
    NSLog(@"didReceiveData");
} 

/**
 !!! FIXME
 
 This event notification system needs to be factored into its own set of classes, but,
 since we only have one web client method, it will do for now.
 */
- (void) notifyEventListenersOfLoginCompletion : (BOOL) completionSuccessful
{
    for(id eventListener in eventListeners)
    {
        if([eventListener respondsToSelector:@selector(bmaWebClient:didCompleteLogin:)])
        {
            [eventListener bmaWebClient:self didCompleteLogin:completionSuccessful];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection 
{ 
    BOOL loginSuccessful = YES;
    [self notifyEventListenersOfLoginCompletion:loginSuccessful];
    [self closeConnection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{ 
    NSLog(@"%@", error);
    
    BOOL loginFailed = NO;
    [self notifyEventListenersOfLoginCompletion:loginFailed];
    [self closeConnection];
}    


- (void) logOutOfBmaWebSiteAsync
{
    if([BMANetworkUtilities anyNetworkConnectionIsAvailable])
    {
        NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
        [request setURL:[NSURL URLWithString:@"https://bouldermountainbike.org/logout"]];  
        [request setHTTPMethod:@"POST"];  
        
        [self closeConnection];
        
        urlConnection =[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    else
    {
        NSLog(@"No available network connections");
    }

}

- (void) addEventNotificationDelegate : (id) instanceToBeNotified
{
    [eventListeners addObject:instanceToBeNotified];
}

- (void) removeEventNotificationDelegate : (id) instanceToBeRemoved
{
    [eventListeners removeObject:instanceToBeRemoved];
}

@end
