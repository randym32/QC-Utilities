//
//  IsBound.m
//  QC Utils
//
//  Created by Randall Maas on 2/16/14.
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

#import "IsBound.h"
#import "ExceptionUnhandled.h"

@implementation IsStringBound

/// Holds the attributes for this plugin
static NSDictionary* IsStringPortAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    IsStringPortAttributes =
    @{
      @"inputObject":
          @{
              QCPortAttributeNameKey        : @"input",
              QCPortAttributeDefaultValueKey: @"",
              QCPortAttributeTypeKey: QCPortTypeString
            },
      @"outputIsBound":
          @{
              QCPortAttributeNameKey: @"is bound",
              QCPortAttributeTypeKey: QCPortTypeBoolean
            },
      @"outputIsFree":
          @{
              QCPortAttributeNameKey: @"is free",
              QCPortAttributeTypeKey: QCPortTypeBoolean
            }
      };
}

/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputObject, outputIsBound, outputIsFree;

+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"Is String Bound",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility/String"],
             QCPlugInAttributeDescriptionKey: @"Checks that the port has a bound value or structure.\n\n"
             };
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return IsStringPortAttributes[key];
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
    // We recompute only if things have changed or the start of time
    if (![self didValueForInputKeyChange:@"inputObject"]
       && time)
    {
        return YES;
    }

    // Check to see if null
    if (!self . inputObject
        || [NSNull null] == (NSNull*) self . inputObject
        || [@"" isEqual: self.inputObject]
        || ([self.inputObject isKindOfClass:[NSArray      class]] && ![(NSArray*)     self.inputObject count])
        || ([self.inputObject isKindOfClass:[NSDictionary class]] && ![(NSDictionary*)self.inputObject count])
        )
    {
        self . outputIsFree = true;
        self . outputIsBound= false;
    }
    else
    {
        self . outputIsFree = false;
        self . outputIsBound= true;
    }
    
	return YES;
}


@end

@implementation IsStructureBound
/// Holds the attributes for this plugin
static NSDictionary* IsStructurePortAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    IsStructurePortAttributes =
    @{
      @"inputObject":
          @{
              QCPortAttributeNameKey        : @"input",
              QCPortAttributeDefaultValueKey: @"",
              QCPortAttributeTypeKey: QCPortTypeStructure
              },
      @"outputIsBound":
          @{
              QCPortAttributeNameKey: @"is bound",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              },
      @"outputIsFree":
          @{
              QCPortAttributeNameKey: @"is free",
              QCPortAttributeTypeKey: QCPortTypeBoolean
              }
      };
}

+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"Is Structure Bound",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility/Structure"],
             QCPlugInAttributeDescriptionKey: @"Checks that the port has a bound value or structure.\n\n"
             };
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return IsStructurePortAttributes[key];
}

@end

