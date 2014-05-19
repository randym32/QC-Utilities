//
//  URLParse.m
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


#import "URLParse.h"

@implementation URLParse
/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputURL, outputStructure, outputIsFileURL, outputStandardizedURL, outputError;


/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
      @"inputURL":
          @{
              QCPortAttributeNameKey        : @"File path or URL",
              QCPortAttributeDefaultValueKey: @"",
              QCPortAttributeTypeKey        : QCPortTypeString
              },
      @"outputStructure":
          @{
              QCPortAttributeNameKey: @"output",
              QCPortAttributeTypeKey: QCPortTypeStructure
              },
      @"outputIsFileURL":
          @{
              QCPortAttributeNameKey: @"is file",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              },
      @"outputStandardizedURL":
          @{
              QCPortAttributeNameKey: @"standardized URL",
              QCPortAttributeTypeKey: QCPortTypeString
              },
      @"outputError":
          @{
              QCPortAttributeNameKey: @"error",
              QCPortAttributeTypeKey: QCPortTypeStructure
              },
      };
}


+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"URL Parser",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility/Structure", @"Utility/String", @"Utility/Network"],
             QCPlugInAttributeDescriptionKey: @"Parses a URL string.\n\n"
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
    // Check for any changes
    if (![self didValueForInputKeyChange:@"inputURL"] && time )
        return YES;

//    NSLog(@"rcm %@ cwd: %@", self.inputURL,
//          [[NSFileManager defaultManager] currentDirectoryPath]);
    
    // create a URL
    NSURL* url = [NSURL URLWithString:self.inputURL];
    // If it is just a file name, we have to try a backup method
    if (!url)
        url = [NSURL fileURLWithPath:self.inputURL];
    // Update our results
    NSURL* tmp =  [url standardizedURL];
    self . outputStandardizedURL = tmp?[tmp description] :@"";
    // If it is a file do something different than if it is a full item)
    if ([url isFileURL])
    {
        self . outputIsFileURL = true;
        self . outputStructure =
            @{
                @"absolute"         : _n([url absoluteString]),
                // The relative portion of a URL.  If baseURL is nil this is the same as absolute
                @"relative"         : _n([url relativeString]),
                // The same as path if baseURL is nil
                @"relativePath"     : _n([url relativePath]),
                @"base"             : _n([url baseURL]),
                @"absolute"         : _n([url absoluteString]),
                @"extension"        : _n([url pathExtension])
             };
        // Check for error's accessingit
        NSError* e= nil;
        [url checkResourceIsReachableAndReturnError: &e];
        self . outputError= NSError2Struct(e);
    }
    else
    {
        self . outputError = @[];
        self . outputStructure =
            @{
                @"absolute"         : _n([url absoluteString]),
                @"absolute URL"     : _n([[url absoluteURL] description]),
                // The relative portion of a URL.  If baseURL is nil this is the same as absolute
                @"relative"         : _n([url relativeString]),
                // The same as path if baseURL is nil
                @"relativePath"     : _n([url relativePath]),
                @"base"             : _n([[url baseURL] description]),
                @"extension"        : _n([url pathExtension]),
                @"scheme"           : _n([url scheme]),
                @"resourceSpecifier": _n([url resourceSpecifier]),
            
                /* If the URL conforms to rfc 1808 (the most common form of URL), the following accessors will return the
                   various components; otherwise they return nil.  The litmus test for conformance is as recommended in
                   RFC 1808 - whether the first two characters of resourceSpecifier is @"//".  In all cases, they return the
                   component's value after resolving the receiver against its base URL.
                */
                @"host"             : _n([url host]),
                @"port"             : _n([url port]),
                @"user"             : _n([url user]),
                @"password"         : _n([url password]),
                @"path"             : _n([url path]),
                @"fragment"         : _n([url fragment]),
                @"parameters"       : _n([url parameterString]),
                @"query"            : _n([url query]),
            };
    }

	return YES;
}


@end
