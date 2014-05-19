//
//  URLParse.h
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

@interface URLParse : QCPlugIn
/* Declare a property input port of type "String" and with the key "inputURL"
   This is the URL for the string (or text file).
 */
@property(assign) NSString* inputURL;

/* If the URL conforms to rfc 1808 (the most common form of URL), the following accessors will return the various components; otherwise they return nil.  The litmus test for conformance is as recommended in RFC 1808 - whether the first two characters of resourceSpecifier is @"//".  In all cases, they return the component's value after resolving the receiver against its base URL.
 */
@property(assign) NSDictionary* outputStructure;

/* Declare a property output port of type "Boolean" and with the key "outputIsFileURL" */
// Whether the scheme is file:
@property(assign) BOOL outputIsFileURL;

/* Declare a property output port of type "String" and with the key "outputStandardizedURL" */
@property(assign) NSString* outputStandardizedURL;

/* Declare a property output port of type "Structure" and with the key "outputError" */
@property(assign) NSArray* outputError;

@end
