/*
     File: Reachability.h
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

#import <Foundation/Foundation.h>
#import <netinet/in.h>


extern NSString *kReachabilityChangedNotification;

/** This is a class that is used to track the availability of the network and hosts
 */
@interface Reachability : NSObject
/// Indicates whether a local WiFi connection is available.
@property(readonly) BOOL reachable;

/// True if a connection is required.
/// WiFi may require a connection for VPN on Demand.
///  WWAN may be available, but not active until a connection has been established.
@property(readonly) BOOL connectionRequired;

/// Reachable via the WWAN (GSM, Edge, etc); always false if not on the phone
@property(readonly) BOOL reachableViaWWAN;

/*! Use to check the reachability of a given host name.
    @param hostName  The host to check for availability
 */
+ (instancetype)reachabilityWithHostName:(NSString *)hostName;


/*! Use to check the reachability of a given IP address.
    @param hostAddress The host to check for availability
 */
+ (instancetype)reachabilityWithAddress:(const struct sockaddr_in *)hostAddress;

/*! Checks whether the default route is available.
    Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForInternetConnection;


/*! Checks whether the default route is available.
 Should be used by applications that do not connect to a particular host.
 */
+ (instancetype)reachabilityForLocalWiFi;

@end


