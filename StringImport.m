//
//  StringImport
//  QC Utils
//
//  Created by Randall Maas on 2/15/14.
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


#import "StringImport.h"

/** This is a patch to load the a JSON file from storage or remotely.
    It does the loading using a Grand Central Dispatch Queue -- ie a background thread.
    The Quartz Composer is allowed to do other things while it loads.
    To let QC know that the loading is done, we use a timebase, and tell QC the interval to poll us
    for results from the background thread.
 */
@implementation StringImport
/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
      @"inputURL":
          @{
              QCPortAttributeNameKey        : @"File path or URL for string",
              QCPortAttributeDefaultValueKey: @"",
              QCPortAttributeTypeKey        : QCPortTypeString
           },
      @"outputString":
          @{
              QCPortAttributeNameKey: @"string",
              QCPortAttributeTypeKey: QCPortTypeString
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

/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputURL, outputString, outputError, outputReady;

+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"String Importer",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility", @"Utility/File", @"Utility/String"],
             QCPlugInAttributeDescriptionKey: @"Imports a string from a file or URL.\n\n"
                                              @"It first assumes that it was given a file path and tries to load from that.  "
                                              @"If that doesn't work, it assumes that it was given an URL and tries to load from that."
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
    state = 0;
    return YES;
}

// - (void) stopExecution:(id<QCPlugInContext>)context
- (void) load: (NSString*) path
{
    // Try loading the data as file
    NSError *e = nil;
    state = 0;
    NSData* data = [NSData dataWithContentsOfFile: path
                                          options: 0
                                            error: &e];
    if (!data)
    {
        // That didn't work.  Try loading it from a URL (which can be slow)
        // We will background the download and come back later
        // First, create an error message, for the duration:
        errorMsg =  NSError2Struct(e);
        state = 1;

        e = nil;
        NSURL* url =[NSURL URLWithString: path];
        // If it is just a file name, we have to try a backup method
        if (!url)
            url = [NSURL fileURLWithPath:self.inputURL];
        // We have to do this as the path may not be a valid URL and return a null
        if (url)
            data = [NSData dataWithContentsOfURL: url
                                         options: 0
                                           error:&e];

        // Check to see if there is any data
        if (!data)
        {
            errorMsg =  NSError2Struct(e);
        }
        else
        {
            errorMsg = @[];
        }
    }

    if (data)
    {
        // convert to a regular file
        string = [[NSString alloc] initWithData: data
                                       encoding: NSUTF8StringEncoding];
    }
    state = 2;
}


/**@brief Tell QC how frequently to poll us for updates; it depends on whether are waiting for
    for results from the network
 */
- (NSTimeInterval) executionTimeForContext:(id<QCPlugInContext>)context
                                    atTime:(NSTimeInterval)time
                             withArguments:(NSDictionary*)arguments
{
    // See if we are waiting on stuff and should just check
    if (state < 3)
        return 0.001;
    // Check to see if an input change
    if ([self didValueForInputKeyChange:@"inputURL"])
        return 0.0;
    return 100000000.0;
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
    if ([self didValueForInputKeyChange:@"inputURL"] || (!string && !state) )
    {
        // try loading the URL
        // The "preferred" way in 10.9 is use NSURLSession, but I'm using 10.8
        NSString* url = self.inputURL;
        state = 1;
        errorMsg = nil;
        string = nil;
        errorMsg = self . outputError= @[];
        self . outputString = @"";
        self . outputReady=false;
        // This doesn't use the main queue cuz some URL connections will cause the QC to stop responding
        // and give a beach ball of death
        if (!url || [@"" isEqualToString: url])
        {
            state = 3;
        }
        else
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)
                           {
                               @autoreleasepool
                               {
                                   [self load:url];
                               }
                           });
        return YES;
    }

    // See if we are done processing yet
    if (state < 2)
        return YES;

    // Update our results
    state = 3;
    self . outputString = string;
    self . outputError = errorMsg;
    self . outputReady = (string != nil) && ![@"" isEqual: string];
	return YES;
}

@end
