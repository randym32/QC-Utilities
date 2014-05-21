//
//  JSONConvert.m
//  QC Utils
//
//  Created by Randall Maas on 5/16/14.
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


#import "JSONConvert.h"
#import "ExceptionUnhandled.h"

@implementation JSONConvert
/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputJSON, outputStructure, outputError, outputReady;


/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
      @"inputJSON":
          @{
              QCPortAttributeNameKey        : @"JSON data",
              QCPortAttributeDefaultValueKey: @"",
              QCPortAttributeTypeKey        : QCPortTypeString
            },
      @"outputStructure":
          @{
              QCPortAttributeNameKey: @"output",
              QCPortAttributeTypeKey: QCPortTypeStructure
            },
      @"outputError":
          @{
              QCPortAttributeNameKey: @"error",
              QCPortAttributeTypeKey: QCPortTypeStructure
            },
      @"outputReady":
          @{
              QCPortAttributeNameKey: @"ready",
              QCPortAttributeTypeKey: QCPortTypeBoolean
            }
      };
}


+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"JSON Converter",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility/Structure", @"Utility/String"],
             QCPlugInAttributeDescriptionKey: @"Parses a JSON string.\n\n"
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


- (BOOL) startExecution:(id<QCPlugInContext>)context
{
    // Initialize the state
    state = 0;
    return YES;
}


/*
 This is used to tell QC how frequently to poll us for updates; it depends on whether are waiting for
 for results from the network
 */
- (NSTimeInterval) executionTimeForContext:(id<QCPlugInContext>)context
                                    atTime:(NSTimeInterval)time
                             withArguments:(NSDictionary*)arguments
{
    // See if we are waiting on stuff and should just check
    if (state < 4)
        return 0.001;
    // Check to see if an input change
    if ([self didValueForInputKeyChange:@"inputJSON"])
        return 0.0;
    return 100000000.0;
}


/**
 This method is called by Quartz Composer whenever the plug-in needs to recompute its result: retrieve the input string and compute the output string
 */
- (BOOL) execute:(id<QCPlugInContext>)context
          atTime:(NSTimeInterval)time
   withArguments:(NSDictionary*)arguments
{
    // Check that this isn't the first call, and that things haven't changed
    if ([self didValueForInputKeyChange:@"inputJSON"] || (!json && !state) )
    {
        state = 1;
        errorMsg = nil;
        json = nil;
        errorMsg = self . outputError= @[];
        self . outputStructure = @{};
        self . outputReady=false;
        NSString* str = self.inputJSON;
        
        // Check that the input is bound
        if (!str || ![str length])
        {
            state =4;
            errorMsg = self . outputError= @[@{@"localizedDescription":@"No JSON data provided or available yet."}];
            return YES;
        }
        
        
        // This doesn't use the main queue cuz some URL connections will cause the QC to stop responding
        // and give a beach ball of death
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                       {
                           @autoreleasepool
                           {
                               state = 2;
                               
                               NSError* e= nil;
                               json = [NSJSONSerialization JSONObjectWithData: [str dataUsingEncoding:NSUTF8StringEncoding]
                                                                      options: 0
                                                                        error: &e];
                               if (!json || e)
                               {
                                   // See if there was an error message
                                   errorMsg =  NSError2Struct(e);
                               }
                               
                               state = 3;
                           }
                       });
        return YES;
    }
    
    // See if we are done processing yet
    if (state < 3)
        return YES;
    
    // Update our results
    state = 4;
    self . outputStructure = json;
    self . outputError = errorMsg;
    self . outputReady = (json != nil) && ![@{} isEqual: json];
	return YES;
}


@end
