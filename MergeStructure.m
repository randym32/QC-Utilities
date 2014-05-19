//
//  MergeStructure.m
//  QC Utils
//
//  Created by Randall Maas on 2/13/14.
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

#import "MergeStructure.h"
#import "ExceptionUnhandled.h"

@implementation MergeStructure

/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputA, inputB, outputStructure;

/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
        @"inputA":
            @{
                QCPortAttributeNameKey: @"structure 1"
             },
        @"inputB":
            @{
                QCPortAttributeNameKey: @"structure 2"
                },
        @"outputStructure":
            @{
                QCPortAttributeNameKey: @"structure"
                }
     };
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return portAttributes[key];
}


+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"Merge Structure",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility/Structure"],
             QCPlugInAttributeDescriptionKey: @"Takes the elements from the second structure and places them into the first, if it doesn't have them defined already"
             };
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

@end

@implementation MergeStructure (Execution)

- (BOOL) execute:(id<QCPlugInContext>)context
          atTime:(NSTimeInterval)time
   withArguments:(NSDictionary*)arguments
{
	/* This method is called by Quartz Composer whenever the plug-in needs to recompute its result: retrieve the input string and compute the output string */
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] initWithDictionary: self . inputA];
    for(NSString* I in self.inputB)
    {
        if (ret[I])
            continue;
        ret[I] = self . inputB[I];
    }
    self . outputStructure = ret;
	
	return YES;
}

@end
