//
//  NetReachability.h
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

#import "QCUtils.h"
#import "src/Reachability.h"


@interface NetReachable : QCPlugIn
{
    /// The monitor specfic to the host we are seeking
    Reachability* netMonitor;
    /// This is how we tell if the data has been updated
    bool volatile changed;
}


/* Declare a property output port of type "Boolean" and with the key "outputConnectionRequired" */
@property(assign) BOOL outputConnectionRequired;

/* Declare a property output port of type "Boolean" and with the key "outputReachable" */
@property(assign) BOOL outputReachable;

/* Declare a property output port of type "Boolean" and with the key "outputReachableViaWWAN" */
@property(assign) BOOL outputReachableViaWWAN;

@end

@interface WiFiReachable : NetReachable
@end

@interface HostReachable : NetReachable

/* Declare a property input port of type "String" and with the key "inputHost"
 This is the host to see if we can reach
 */
@property(assign) NSString* inputHost;

@end