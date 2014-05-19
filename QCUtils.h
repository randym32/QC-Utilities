//
//  QCUtils.h
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


// Macro to make it easier to add to dictionaries
#define _n(a) ((a)?(a):[NSNull null])
#define LogPrefix @"QCUtils: "

/** Convert an NSError to an array of dictionaries suitable for passing to Quartz Composer
    @param e The error to convert
    @returns An array of dictionaries.
 */
extern NSArray* NSError2Struct(NSError* e);

/** A procedure to set up the hook into the exception handling system */
extern void RegisterExceptionHandler(void);
