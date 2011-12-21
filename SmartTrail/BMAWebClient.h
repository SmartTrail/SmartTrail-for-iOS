//
//  BMAWebClient.h
//  SmartTrail
//
//  Created by John Dumais on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMAWebClient : NSObject
{
    NSString *sessionUserName;
    NSString *sessionPassword;
    NSURLConnection *urlConnection;
}

@property (nonatomic, retain) NSString *sessionCookie;

- (void) dealloc;

/**
 This is an asynchronous method.  The intended use is to run this in a separate thread, then
 wait for a non-nil session cookie.
 */
- (void) logIntoBmaWebSiteAsync : (NSString*) withUserName andPassword : (NSString*) passWord;

/**
 This is an asynchronous method.  The intended use is to run this method in a separate thread,
 then wait for the session cookie to become nil.
 */
- (void) logOutOfBmaWebSiteAsync;

@end
