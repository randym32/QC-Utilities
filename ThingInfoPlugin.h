//
//  ThingInfoPlugin.h
//  QC Utilities
//
//  Created by Randall Maas on 5/19/14.
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

/** This maps a device identifier a bunch of information about the device
 */
@interface ThingInfoPlugin : QCPlugIn
/* Declare a property input port of type "String" and with the key "inputIdentifier"
   The identifier for the WLAN or Camera
 */
@property(assign) NSString* inputIdentifier;

/* Declare a property input port of type "Structure" and with the key "outputStructure"
 */
@property(assign) NSDictionary* outputStructure;

@end
