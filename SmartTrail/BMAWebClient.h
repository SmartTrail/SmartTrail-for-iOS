//
//  BMAWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMAWebClient;

#pragma mark - Web client event notification protocol definition

/**
 Define the interface that lets the web client inform its constituents of web 
 service events.
 */
@protocol BMAWebClientNotifications <NSObject>

@optional
/**
 @method         didCompleteLogin:
 
 @abstract
 Gets called when a web request to log into the BMA web site completes.
 
 @discussion
 This delegate method is called when a web request to log into the BMA web site completes.
 Login completion can result from the web client request finishing or failing.
 
 @param 
     bmaWebClient
         The instance of BMAWebClient you used to run a web client login request.
     successfully
         Set to YES if the login request was successful, NO otherwise.
 */
- (void) bmaWebClient : (BMAWebClient*) webClient didCompleteLogin : (BOOL) successfully;

@end

@interface BMAWebClient : NSObject
{
    NSString *sessionUserName;
    NSString *sessionPassword;
    NSURLConnection *urlConnection;
}

@property (nonatomic, retain) NSString *sessionCookie;
@property (nonatomic, retain) id eventListener;

- (id) init;
- (void) dealloc;

/**
 This is an asynchronous method.  The intended use is to call this method from a client
 class that implements one or more of the BMAWebClientNotifications event notification protocol 
 methods.  A client knows a web request has completed when one of the delegate methods gets
 called.
 */
- (void) logIntoBmaWebSiteAsync : (NSString*) withUserName andPassword : (NSString*) passWord;

/**
 This is an asynchronous method.  The intended use is to call this method from a client
 class that implements one or more of the BMAWebClientNotifications event notification protocol 
 methods.  A client knows a web request has completed when one of the delegate methods gets
 called.
 */
- (void) logOutOfBmaWebSiteAsync;

@end
