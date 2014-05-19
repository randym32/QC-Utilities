//
//  NetReachability.m
//  QC Utilities
//
//  Created by Randall Maas on 5/19/14.
//
/*
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


#import "HostReachable.h"

@implementation NetReachable

/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic outputConnectionRequired, outputReachable, outputReachableViaWWAN;

/// Holds the attributes for this plugin
static NSDictionary* netPortAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    netPortAttributes =
    @{
      @"outputConnectionRequired":
          @{
              QCPortAttributeNameKey: @"connection required",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              },
      @"outputReachable":
          @{
              QCPortAttributeNameKey: @"reachable",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              },
      @"outputReachableViaWWAN":
          @{
              QCPortAttributeNameKey: @"reachable via WWAN",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              }
      };
}


+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"Network Reachability",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility", @"Utility/Network"],
             QCPlugInAttributeDescriptionKey: @"Checks that the network is reachable"
             };
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return netPortAttributes[key];
}



+ (QCPlugInExecutionMode) executionMode
{
	/* This plug-in is a provider */
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode
{
    // Either idle or time base.  I'm going with timeBase
	return kQCPlugInTimeModeTimeBase;
}

- (void) dealloc
{
    // Unsubscribe
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}


/**@brief Called by Reachability whenever status changes.
 */
- (void) reachabilityChanged:(NSNotification *)note
{
    // Get the object
	Reachability* curReach = [note object];
    // Check that the class is correct.  (TODO: don't use assert!)
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    changed= true;
}


/** @brief Tell QC how frequently to poll us for updates; it depends on whether are waiting for
 for results from the network
 */
- (NSTimeInterval) executionTimeForContext:(id<QCPlugInContext>)context
                                    atTime:(NSTimeInterval)time
                             withArguments:(NSDictionary*)arguments
{
    // See if we are waiting on stuff and should just check
    if (changed)
    {
        changed = false;
        return 0.0;
    }
    return 100000000.0;
}

- (BOOL)startExecution:(id<QCPlugInContext>)context
{
    // Create monitor to check for internet activity
    netMonitor = [Reachability reachabilityForInternetConnection];
    if (netMonitor)
    {
        /* Observe the kNetworkReachabilityChangedNotification.
         When that notification is posted, the method reachabilityChanged will be called.
         */
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(reachabilityChanged:)
                                                     name: kReachabilityChangedNotification
                                                   object: netMonitor];
        changed= true;
    }
    return YES;
}


- (void) stopExecution:(id<QCPlugInContext>)context
{
    // Unsubscribe
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:netMonitor];
}


/** @brief This method is called by Quartz Composer whenever the plug-in needs to recompute its result
    @param context
    @param time
    @param arguments
 */
- (BOOL) execute:(id<QCPlugInContext>)context
          atTime:(NSTimeInterval)time
   withArguments:(NSDictionary*)arguments
{
    if (!time)
        [self startExecution: context];
    // Update our results
    self . outputConnectionRequired = netMonitor . connectionRequired;
    self . outputReachable          = netMonitor . reachable;
    self . outputReachableViaWWAN   = netMonitor . reachableViaWWAN;
	return YES;
}

@end

@implementation WiFiReachable
+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"WiFi Reachability",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility", @"Utility/Network"],
             QCPlugInAttributeDescriptionKey: @"Checks that the network is reachable"
             };
}

- (BOOL)startExecution:(id<QCPlugInContext>)context
{
    // Create monitor to check for internet activity
    netMonitor = [Reachability reachabilityForLocalWiFi];
    if (netMonitor)
    {
        /* Observe the kNetworkReachabilityChangedNotification.
           When that notification is posted, the method reachabilityChanged will be called.
         */
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(reachabilityChanged:)
                                                     name: kReachabilityChangedNotification
                                                   object: netMonitor];
        changed= true;
    }
    return YES;
}

@end


@implementation HostReachable

/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputHost;

/// Holds the attributes for this plugin
static NSDictionary* hostPortAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    hostPortAttributes =
    @{
      @"inputHost":
          @{
              QCPortAttributeNameKey        : @"Host name or IPAddress",
              QCPortAttributeDefaultValueKey: @"",
              QCPortAttributeTypeKey        : QCPortTypeString
              },
      @"outputConnectionRequired":
          @{
              QCPortAttributeNameKey: @"connection required",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              },
      @"outputReachable":
          @{
              QCPortAttributeNameKey: @"reachable",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              },
      @"outputReachableViaWWAN":
          @{
              QCPortAttributeNameKey: @"reachable via WWAN",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              }
      };
}


+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"Host Reachability",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility", @"Utility/Network"],
             QCPlugInAttributeDescriptionKey: @"Checks that a given host is reachable"
             };
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return hostPortAttributes[key];
}

+ (QCPlugInExecutionMode) executionMode
{
	/* This plug-in is a processor (it just processes and may change with time) */
	return kQCPlugInExecutionModeProcessor;
}

- (BOOL)startExecution:(id<QCPlugInContext>)context
{
    return YES;
}

/** @brief Tell QC how frequently to poll us for updates; it depends on whether are waiting for
 for results from the network
 */
- (NSTimeInterval) executionTimeForContext:(id<QCPlugInContext>)context
                                    atTime:(NSTimeInterval)time
                             withArguments:(NSDictionary*)arguments
{
    // See if we are waiting on stuff and should just check
    // Check to see if an input change
    if ([self didValueForInputKeyChange:@"inputHost"])
        return 0.0;

    return [super executionTimeForContext: context
                                   atTime: time
                            withArguments: arguments];
}


/** @brief This method is called by Quartz Composer whenever the plug-in needs to recompute its result
    @param context
    @param time
   @param arguments
 */
- (BOOL) execute:(id<QCPlugInContext>)context
          atTime:(NSTimeInterval)time
   withArguments:(NSDictionary*)arguments
{
    // Check that this isn't the first call, and that things haven't changed
    if ([self didValueForInputKeyChange:@"inputHost"] || (!time) )
    {
        self . outputConnectionRequired = false;
        self . outputReachable = false;
        self . outputReachableViaWWAN = false;
        netMonitor = [Reachability reachabilityWithHostName: self.inputHost];
        if (netMonitor)
        {
            /* Observe the kNetworkReachabilityChangedNotification.
             When that notification is posted, the method reachabilityChanged will be called.
             */
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(reachabilityChanged:)
                                                         name: kReachabilityChangedNotification
                                                       object: netMonitor];
            changed= true;
        }
        
        
        return YES;
    }
    return [super execute: context
                   atTime: time
            withArguments: arguments];
}

@end
