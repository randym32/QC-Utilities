//
//  DevInfo.m
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


#import "ThingInfo.h"
#import "Cameras.h"

@implementation ThingInfo

/** Look up the device for the given identifier
    @param The identifier
    @returns nil on error; otherwise the device object
 */
+ (NSObject*) deviceForId: (NSString*) id
{
    // See if it is a camera
    NSObject* camera = [[Cameras cameras] cameras][id];
    if (camera)
        return camera;
    // See if it isa bSD name for a WLAN
    CWInterface* interface = [CWInterface interfaceWithName: id];
    if (interface)
        return interface;
    // It was nothing
    return nil;
}

+ (NSDictionary*) deviceInfoForId: (NSString*) id
{
    // See if it is a camera
    NSObject* camera = [[Cameras cameras] cameras][id];
    if (camera)
        return [ThingInfo cameraInfo:(ICDevice*) camera];
    // See if it isa bSD name for a WLAN
    CWInterface* interface = [CWInterface interfaceWithName: id];
    if (interface)
        return [ThingInfo wlanInfo: interface];
    // It was nothing
    return nil;
}
@end
