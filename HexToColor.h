//
//  HexToColor.h
//  QC Utils
//
//  Created by Randall Maas on 2/14/14.
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


/** This is a plugin to convert colors */
@interface HexToColor : QCPlugIn

/* Declare a property input port of type "String" and with the key "key" */
@property(assign) NSString* inputHexString;

/* Declare a property input port of type "Object" and with the key "defaultValue" */
@property(assign) CGColorRef inputDefaultColor;

/* Declare a property output port of type "Structure" and with the key "output" */
@property(assign) CGColorRef outputColor;

@end
