//
//  Error2Structure.c
//  QC Utils
//
//  Created by Randall Maas on 5/16/14.
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


#import "QCUtils.h"


/*
 The structure is defined as:
 localizedDescription.
 The primary user-presentable message for the error... In the absence of a custom error string, the manufactured one might not be suitable for presentation to the user, but can be used in logs or debugging.
 
 localizedFailureReason
 A complete sentence which describes why the operation failed. In many cases this will be just the "because" part of the error message (but as a complete sentence, which makes localization easier).
 
 
 localizedRecoverySuggestion
 The string that can be displayed as the "informative" (aka "secondary") message on an alert panel.
 
 localizedRecoveryOptions
 Titles of buttons that are appropriate for displaying in an alert. These should match the string provided as a part of localizedRecoverySuggestion.  The first string would be the title of the right-most and default button, the second one next to it, and so on. If used in an alert the corresponding default return values are NSAlertFirstButtonReturn + n. Default implementation of this will pick up the value of the NSLocalizedRecoveryOptionsErrorKey from the userInfo dictionary.  nil return usually implies no special suggestion, which would imply a single "OK" button.
 
 recoveryAttempter
 An object that conforms to the NSErrorRecoveryAttempting informal protocol. The recovery attempter must be an object that can correctly interpret an index into the array returned by -localizedRecoveryOptions. The default implementation of this method merely returns [[self userInfo] objectForKey:NSRecoveryAttempterErrorKey].
 
 helpAnchor
 The help anchor that can be used to create a help button to accompany the error when it's displayed to the user.
 */

static void add(NSMutableDictionary* d, NSString* key, NSObject* value)
{
    if (value && ![@"" isEqual:value] && [NSNull null] != value)
        d[key] = value;
}

NSArray* NSError2Struct(NSError* e)
{
    if (!e)
        return @[];
    NSMutableArray* stack = [[NSMutableArray alloc] init];
    while (e)
    {
        NSMutableDictionary* tmp = [[NSMutableDictionary alloc] init];
        // See if there was an error message
        add(tmp, @"localizedDescription",       [e localizedDescription]);
        add(tmp, @"localizedFailureReason",     [e localizedFailureReason]);
        add(tmp, @"localizedRecoverySuggestion",[e localizedRecoverySuggestion]);
        add(tmp, @"localizedRecoveryOptions",   [e localizedRecoveryOptions]);
        add(tmp, @"recoveryAttempter",          [e recoveryAttempter]);
        add(tmp, @"helpAnchor",                 [e helpAnchor]);
         
        [stack insertObject: tmp
                    atIndex: 0];
        e= [[e userInfo] objectForKey:NSUnderlyingErrorKey];
    }
    return stack;
}

