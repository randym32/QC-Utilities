/*
     File: Reachability.m
 Abstract: Tracks the availability of hosts and networks via the SystemConfiguration Reachablity APIs.
    Created by Randall Maas on 5/19/14.
    Portions from Apple

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
 
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
 
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
 */

#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

/// The notification string used to signal when there is a change in the network
NSString *kReachabilityChangedNotification = @"kNetworkReachabilityChangedNotification";

/// A helper procedure
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info);



#pragma mark - Reachability implementation

@implementation Reachability
{
	SCNetworkReachabilityRef _reachabilityRef;
}

+ (instancetype)reachabilityWithHostName:(NSString *)hostName
{
    return  [[self alloc] initWithReachability:  SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String])];
}


+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress
{
    return [[self alloc] initWithReachability:
            SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)hostAddress)];
}


+ (instancetype)reachabilityForInternetConnection
{
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
    
	return [self reachabilityWithAddress:&zeroAddress];
}


+ (instancetype)reachabilityForLocalWiFi
{
	struct sockaddr_in localWifiAddress;
	bzero(&localWifiAddress, sizeof(localWifiAddress));
	localWifiAddress.sin_len = sizeof(localWifiAddress);
	localWifiAddress.sin_family = AF_INET;

	// IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0.
	localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);

	return [self reachabilityWithAddress: &localWifiAddress];
}


#pragma mark - Initialization
@synthesize connectionRequired, reachable, reachableViaWWAN;
- (id)init
{
    // We must have a reachability reference
    return nil;
}

- (id) initWithReachability:(SCNetworkReachabilityRef) ref
{
    if (!(self = [super init]))
    {
        CFRelease(ref);
        return nil;
    }
    _reachabilityRef = ref;

    // Start listening for reachability notifications on the current run loop.
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
	if (  !ref
       || !SCNetworkReachabilitySetCallback(_reachabilityRef, ReachabilityCallback, &context)
       || !SCNetworkReachabilityScheduleWithRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
    {
        // There was a problem setting it up, bail
        return nil;
	}
    
    [self updateReachabilityStatus];
    
    return self;
}

- (void)dealloc
{
    // Disable notifications
    SCNetworkReachabilityUnscheduleFromRunLoop(_reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	if (_reachabilityRef != NULL)
	{
		CFRelease(_reachabilityRef);
	}
}

#pragma mark - Network Flag Handling


/// This is updates the local properties with the new information about the connection
- (void) updateReachabilityStatus
{
	SCNetworkReachabilityFlags flags;

    // Check to see if the network is reachable
	if (!SCNetworkReachabilityGetFlags(_reachabilityRef, &flags))
	{
		// The target host is not reachable.
        reachable = false;
		reachableViaWWAN = false;
		return;
	}

    // Check to see if we need to make a connection
    connectionRequired = (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    
    // Check the reachability settings
    if (!(flags & kSCNetworkReachabilityFlagsReachable))
	{
		// The target host is not reachable.
        reachable = false;
		reachableViaWWAN = false;
		return;
	}
    
#if	TARGET_OS_IPHONE
    // WWAN connections are OK if the calling application is using the CFNetwork APIs.
    reachableViaWWAN = ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN);
#endif
    
    // We are reachable or it is local in the system
    reachable = ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect));
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		/*
         If the target host is reachable and no connection is required then we'll assume (for now) that you're on Wi-Fi...
         */
		reachable = true;
	}
    
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        /*
         ... and the connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs...
         */
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed...
            reachable = true;
        }
    }
}

@end


/** This is a callback used to post updates to the system when something has changed.
 */
static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
	NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
	NSCAssert([(__bridge NSObject*) info isKindOfClass: [Reachability class]], @"info was wrong class in ReachabilityCallback");
    
    Reachability* noteObject = (__bridge Reachability *)info;
    [noteObject updateReachabilityStatus];
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: kReachabilityChangedNotification
                                                        object: noteObject];
}