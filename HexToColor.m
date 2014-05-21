//
//  HexToColor.m
//  QC Utils
//
//  Created by Randall Maas on 2/14/14.
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

#import "HexToColor.h"
#import "ExceptionUnhandled.h"

@implementation HexToColor


/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputHexString, inputDefaultColor, outputColor;

/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
      @"inputHexString":
          @{
              QCPortAttributeNameKey : @"hex RGB",
              QCPortAttributeDefaultValueKey: @""
            },
      @"inputDefaultColor":
          @{
              QCPortAttributeNameKey : @"default color",
              QCPortAttributeTypeKey : QCPortTypeColor,
              QCPortAttributeDefaultValueKey: [NSColor clearColor]
          },
      @"outputColor":
          @{
              QCPortAttributeNameKey: @"color",
              QCPortAttributeTypeKey: QCPortTypeColor
              }
      };
}
+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"Hex to Color",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility/Color"],
             QCPlugInAttributeDescriptionKey: @"Converts the RGB to a color."
             };
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return portAttributes[key];
}


+ (QCPlugInExecutionMode) executionMode
{
	/* This plug-in is a processor (it just processes a structure) */
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode) timeMode
{
	/* This plug-in does not depend on the time (time parameter is completely ignored in the -execute:atTime:withArguments: method) */
	return kQCPlugInTimeModeNone;
}


- (void)dealloc
{
    CGColorRelease(self.outputColor);
}

// - (BOOL) startExecution:(id<QCPlugInContext>)context
// - (void) stopExecution:(id<QCPlugInContext>)context
// Note to self: we can't use any of the outputs at this point in  those procedures

/**
 This method is called by Quartz Composer whenever the plug-in needs to recompute its result: retrieve the input string and compute the output string
 */
- (BOOL) execute:(id<QCPlugInContext>)context
          atTime:(NSTimeInterval)time
   withArguments:(NSDictionary*)arguments
{
    // We only recalculate at the start of time, or the inputs have changed
    if (![self didValueForInputKeyChange:@"inputHexString"]
        && ![self didValueForInputKeyChange:@"inputDefaultColor"]
        && time)
    {
        return YES;
    }

    NSScanner *scanner = [NSScanner scannerWithString:self.inputHexString];
    unsigned rgbValue;

    // Scan the input hex string into a number
    if ([scanner scanHexInt:&rgbValue])
    {
        CGColorRelease(self.outputColor);
        self . outputColor = CGColorCreateGenericRGB(((CGFloat)(0xFF & (rgbValue >> 16)))/255.0,
                                                     ((CGFloat)(0xFF & (rgbValue >>  8)))/255.0,
                                                     ((CGFloat)(0xFF & rgbValue))/255.0,
                                                     1.0);
    }
    else
    {
        CGColorRelease(self.outputColor);
        self . outputColor = CGColorRetain(self . inputDefaultColor);
	}
	return YES;
}

@end
