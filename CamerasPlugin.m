//
//  Cameras.m
//  QC Utilities
//
//  Created by Randall Maas on 5/20/14.
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


#import "CamerasPlugin.h"
#import "src/Cameras.h"

@implementation CamerasPlugin
{
    uint changeCount;
}
/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic outputCameraIds;

/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
      @"outputCameraIds":
          @{
              QCPortAttributeNameKey: @"camera ids",
              QCPortAttributeTypeKey: QCPortTypeStructure
          },
      };
}

+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"Cameras",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility", @"Video"],
             QCPlugInAttributeDescriptionKey: @"Gets the table of cameras.\n\n"
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
	return kQCPlugInTimeModeTimeBase;
}



/**@brief Tell QC how frequently to poll us for updates; it depends on whether are waiting for
 for results from the network
 */
- (NSTimeInterval) executionTimeForContext:(id<QCPlugInContext>)context
                                    atTime:(NSTimeInterval)time
                             withArguments:(NSDictionary*)arguments
{
    uint newChangeCount = [[Cameras cameras] changeCount];
    if (newChangeCount == changeCount)
        return 100000000.0;
    changeCount = newChangeCount;
    return 0.001;
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
    // Get all of the ids
    self . outputCameraIds = [[[Cameras cameras] cameras] allKeys];
	return YES;
}


@end
