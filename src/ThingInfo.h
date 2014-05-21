//
//  DevInfo.h
//  QC Utilities
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

#import "../QCUtils.h"
#import <Foundation/Foundation.h>
#import <CoreWLAN/CoreWLAN.h>

/** A class to get information about devices by their identifier
 */
@interface ThingInfo : NSObject

/** Look up the device for the given identifier
    @param The identifier
    @returns nil on error; otherwise the device object
 */
+ (NSObject*) deviceForId: (NSString*) id;
+ (NSDictionary*) deviceInfoForId: (NSString*) id;
@end

// Support the cameras
@interface ThingInfo(Camera) //, ICCameraDeviceDelegate, ICCameraDeviceDownloadDelegate>
/**@brief Convert the device node into a structure 
   @param device  The camera/scanner device to convert
   @returns Dictionary of key/value pairs
*/
+ (NSDictionary*) cameraInfo: (ICDevice*) device;
@end

// Support the WLANs
@interface ThingInfo(WLAN)
/**@brief Convert the device node into a structure
   @param interface  The WLAN device to convert
   @returns Dictionary of key/value pairs
*/
+ (NSDictionary*) wlanInfo: (CWInterface*) interface;
@end

