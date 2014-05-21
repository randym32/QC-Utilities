//
//  Applications.m
//  BW QC Utilities
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

#import <AppKit/AppKit.h>

#import "Applications.h"

@implementation Applications
static NSMutableDictionary* ApplicationsByBundle;

+ (void) Applications
{
    NSWorkspace* workspace = [NSWorkspace sharedWorkspace];

    // Get the set of applications
    NSArray* Applications = [workspace runningApplications];
    // Create the table applications by id
    ApplicationsByBundle = [[NSMutableDictionary alloc] init];
    for (NSRunningApplication* app in Applications)
    {
        ApplicationsByBundle[app.bundleIdentifier] = app;
    }
    
    // Get updates
    /* Register for application launch notifications */
    [[workspace notificationCenter] addObserver:self
                                       selector:@selector(applicationLaunched:)
                                           name:NSWorkspaceDidLaunchApplicationNotification
                                         object:workspace];
	/* Register for application termination notifications */
    [[workspace notificationCenter] addObserver:self
                                       selector:@selector(applicationTerminated:)
                                           name:NSWorkspaceDidTerminateApplicationNotification
                                         object:workspace];

}


/*
 Called when a new application was launched. Registers for its notifications when the
 application is activated.
 */
- (void)applicationLaunched:(NSNotification *)notification
{
    // Get the application
    NSRunningApplication* app = (NSRunningApplication*) [notification userInfo][NSWorkspaceApplicationKey];
    // Add to the set of applications
    if (app)
        ApplicationsByBundle[app.bundleIdentifier] = app;
}


/*
 Called when an application was terminated. Stops watching for this application switch events.
 */
- (void)applicationTerminated:(NSNotification *)notification
{
    // Get the application
    NSRunningApplication* app = (NSRunningApplication*) [notification userInfo][NSWorkspaceApplicationKey];
    // Remove it from the set of applications
    if (app)
        [ApplicationsByBundle removeObjectForKey: app.bundleIdentifier];
}

@end
