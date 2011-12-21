//
//  BMANetworkUtilities.m
//  SmartTrail
//
//  Created by John Dumais on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BMANetworkUtilities.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <ifaddrs.h>

@implementation BMANetworkUtilities

SCNetworkConnectionFlags connectionFlags;

+ (void) isAnyNetworkReachable
{
    BOOL ignoresAdHocWiFi = NO;
	struct sockaddr_in ipAddress;
	bzero(&ipAddress, sizeof(ipAddress));
	ipAddress.sin_len = sizeof(ipAddress);
	ipAddress.sin_family = AF_INET;
	ipAddress.sin_addr.s_addr = htonl(ignoresAdHocWiFi ? INADDR_ANY : IN_LINKLOCALNETNUM);
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (struct sockaddr *)&ipAddress);    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &connectionFlags);
    CFRelease(defaultRouteReachability);
	if (!didRetrieveFlags) 
    {
        NSLog(@"Error. Could not recover network reachability flags\n");
    }
}

+ (BOOL) anyNetworkConnectionIsAvailable
{
    [self isAnyNetworkReachable];
	BOOL isReachable = ((connectionFlags & kSCNetworkFlagsReachable) != 0);
    BOOL needsConnection = ((connectionFlags & kSCNetworkFlagsConnectionRequired) != 0);
    return (isReachable && !needsConnection) ? YES : NO;
}

@end
