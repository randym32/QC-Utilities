//
//  ExceptionUnhandled.m
//  QC Utils
//
//  Created by Randall Maas on 5/15/14.
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

#import "ExceptionUnhandled.h"

#import <ExceptionHandling/ExceptionHandling.h>

/** A class called by the Objective-C framework to report errors
 */
@interface ExceptionDelegate : NSObject
@end
/** The delegate object to receive calls from the Objective-C runtime when there is unhandled exceptions */
static ExceptionDelegate *exceptionDelegate = nil;

/// An array hold the exceptions (newest first)
static NSMutableArray* exceptions=nil;

/// A signal handler to capture serious events
static void signalHandler(int sig, siginfo_t *info, void *context)
{
    [exceptions addObject: @{@"name":[NSString stringWithFormat:@"signal: %d", sig, nil]}];
    NSLog(LogPrefix @"Caught signal %d", sig);
    NSLog(LogPrefix @"traceback:\n%@", [NSThread callStackSymbols]);
    exit(102);
}

// NSLogUncaughtSystemExceptionMask catches when the Quartz Composer environment synthesizes inputs/outputs
// so don't do that

#define NSLogAndHandleExceptionMask (NSLogUncaughtExceptionMask|NSLogUncaughtRuntimeErrorMask|NSLogTopLevelExceptionMask|NSLogOtherExceptionMask)

/** A procedure to set up the hook into the exception handling system */
void RegisterExceptionHandler()
{
    // Return if the system has already hooked into the excpetion handlers
    if (exceptionDelegate)
        return;
    
    // Set up an array receive exceptions
    exceptions = [[NSMutableArray alloc] init];
    
    //
    // Set exception handler delegate
    //
    exceptionDelegate = [[ExceptionDelegate alloc] init];
    NSExceptionHandler *exceptionHandler = [NSExceptionHandler defaultExceptionHandler];
    exceptionHandler.exceptionHandlingMask = NSLogAndHandleExceptionMask;
    exceptionHandler.delegate = exceptionDelegate;
    
    //
    // Set signal handler
    //
    static const int signals[] =
    {
        SIGQUIT, SIGILL, SIGTRAP, SIGABRT, SIGEMT, SIGFPE, SIGBUS, SIGSEGV,
        SIGSYS, SIGPIPE, SIGALRM, SIGXCPU, SIGXFSZ
    };
    const unsigned numSignals = sizeof(signals) / sizeof(signals[0]);
    struct sigaction sa;
    sa.sa_sigaction = signalHandler;
    sa.sa_flags = SA_SIGINFO;
    sigemptyset(&sa.sa_mask);
    for (unsigned i = 0; i < numSignals; i++)
        sigaction(signals[i], &sa, NULL);
}


@implementation ExceptionDelegate

// this controls whether the exception shows up in the console, just return YES
- (BOOL)exceptionHandler:(NSExceptionHandler *)exceptionHandler
      shouldLogException:(NSException *)exception
                    mask:(NSUInteger)mask
{
    // Get the call stack
    NSArray* callStack = [exception callStackSymbols];
    if (!callStack)
        callStack = [NSThread callStackSymbols];
    NSLog(LogPrefix @"An unhandled exception occurred: %@\ncall stack: %@", [exception reason], callStack);
    // Prepend the exception
    [exceptions insertObject:
                      @{
                            @"name"     : _n([exception name]),
                            @"reason"   : _n([exception reason]),
                            @"callStack": _n(callStack),
                            @"userInfo" : _n([exception userInfo])
                        }
                     atIndex: 0];
    return YES;
}

- (BOOL)exceptionHandler:(NSExceptionHandler *)exceptionHandler
   shouldHandleException:(NSException *)exception
                    mask:(NSUInteger)mask
{
    // used to filter out some common harmless exceptions
    NSString* name = [exception name];
    NSString* reason = [exception reason];
    
    if ([name isEqualToString:@"NSImageCacheException"] ||
        [name isEqualToString:@"GIFReadingException"] ||
        [name isEqualToString:@"NSRTFException"] ||
        ([name isEqualToString:@"NSInternalInconsistencyException"] && [reason hasPrefix:
                                                                        @"lockFocus"])
        )
    {
        return YES;
    }

    // We often get exceptions for unhandled exceptions from selectors that Quartz Composer is to dynamically create
    NSLog(LogPrefix @"handle: %@", [exception name]);
    [exceptions addObject:
     @{
       @"name"  : _n([exception name]),
       @"reason": _n([exception reason]),
       @"userInfo": _n([exception userInfo])
       }];
    
    return YES;
}

@end


@implementation ExceptionUnhandled
/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic outputError;


/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
      @"outputError":
          @{
              QCPortAttributeNameKey: @"error",
              QCPortAttributeTypeKey: QCPortTypeStructure
            }
      };
}


+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"Exception (Unhandled) Reporter",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility"],
             QCPlugInAttributeDescriptionKey: @"Reports runtime exceptions, to help track down bugs."
             };
}


+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return portAttributes[key];
}


+ (QCPlugInExecutionMode) executionMode
{
	/* This plug-in is a provider  */
	return kQCPlugInExecutionModeProvider;
}

+ (QCPlugInTimeMode) timeMode
{
	/* This plug-in does not depend on the time (time parameter is completely ignored in the -execute:atTime:withArguments: method) */
	return kQCPlugInTimeModeNone;
}

- (BOOL) startExecution:(id<QCPlugInContext>)context
{
    // Clear out the pool of exceptions
    exceptions = [[NSMutableArray alloc] init];
    // Note to self: we can't use any of the outputs at this point in time
    return YES;
}


// - (BOOL) startExecution:(id<QCPlugInContext>)context
// - (void) stopExecution:(id<QCPlugInContext>)context
// Note to self: we can't use any of the outputs at this point in  those procedures

/**
 This method is called by Quartz Composer whenever the plug-in needs to recompute its result: retrieve the input string and compute the output string
 */
- (BOOL) execute:(id<QCPlugInContext>)context
          atTime:(NSTimeInterval)     time
   withArguments:(NSDictionary*)      arguments
{
    // Update the output at the very start of time
    if (!time)
    {
        self . outputError = exceptions;
    }
	return YES;
}

@end
