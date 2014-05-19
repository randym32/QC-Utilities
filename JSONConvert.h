//
//  JSONConvert.h
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


#import <Quartz/Quartz.h>

@interface JSONConvert : QCPlugIn
{
    // The state is 0: starting, 1: trying to load, 2:
    int volatile state;
    // The loaded json data
    NSDictionary* volatile json;
    // The error message, if any
    NSArray* volatile errorMsg;
}

/* Declare a property input port of type "String" and with the key "inputJSON"
 This is the JSON string.
 */
@property(assign) NSString* inputJSON;

/* Declare a property output port of type "Structure" and with the key "outputStructure" */
@property(assign) NSDictionary* outputStructure;

/* Declare a property output port of type "Structure" and with the key "outputError" */
@property(assign) NSArray* outputError;

/* Declare a property output port of type "Boolean" and with the key "outputReady" */
@property(assign) BOOL outputReady;

@end
