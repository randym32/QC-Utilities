//
//  WLANs.m
//  QC Utilities
//
//  Created by Randall Maas on 5/19/14.
//
//

#import "WLANs.h"
#import <CoreWLAN/CoreWLAN.h>

@implementation WLANs
/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic outputWLANs;


/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
      @"outputWLANs":
          @{
              QCPortAttributeNameKey: @"WLANs",
              QCPortAttributeTypeKey: QCPortTypeStructure
              },
      };
}


+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"WLANs",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility/Network"],
             QCPlugInAttributeDescriptionKey: @"Returns the array of WLAN local (internal BSD interface) names.\n\n"
             };
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return portAttributes[key];
}


+ (QCPlugInExecutionMode) executionMode
{
	/* This plug-in is a processor (it just processes and may change with time) */
	return kQCPlugInExecutionModeProcessor;
    //
}

+ (QCPlugInTimeMode) timeMode
{
    // Either idle or time base.  I'm going with timeBase
	return kQCPlugInTimeModeNone;
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
    if (time) return YES;
    self . outputWLANs = [[CWInterface interfaceNames] allObjects];
    
	return YES;
}


@end


