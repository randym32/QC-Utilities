//
//  Cameras.m
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


#import "Cameras.h"

@implementation Cameras
{
    /// This is the table of known cameras
    /// The key is the UUID of the camera
    NSMutableDictionary* _cameras;

    /// The link to the system so that we can get all of the cameras
    ICDeviceBrowser* deviceBrowser;
    
    /// This is how we track changes
    uint volatile _changeCount;
}

/// This gets the single instance needed to work with everything
+ (instancetype) cameras
{
    // Hold the global instance
    static Cameras* _cameras= nil;

    // Allocate the shared instance
    if (!_cameras)
        _cameras = [[Cameras alloc] initShared];

    // Return the shared instance
    return _cameras;
}

// Dummy since no one should use it
- (id) init
{
    return nil;
}

/// Initialize the shared version of the camera browser
- (id)initShared
{
    // Tradition: initialize in the base
    if (!(self = [super init]))
        return self;
    
    // Allocate the table to hold the cameras
    _cameras = [[NSMutableDictionary alloc] init];

    // Get an instance of ICDeviceBrowser
    deviceBrowser = [[ICDeviceBrowser alloc] init];
    // Assign a delegate
    deviceBrowser.delegate = self;
    // Look for cameras in all available locations
    deviceBrowser.browsedDeviceTypeMask|= ICDeviceTypeMaskCamera
                                       |  ICDeviceLocationTypeMaskLocal
                                       |  ICDeviceLocationTypeMaskShared
                                       |  ICDeviceLocationTypeMaskBonjour
                                       |  ICDeviceLocationTypeMaskBluetooth
                                       |  ICDeviceLocationTypeMaskRemote;
    // Start browsing for cameras
    [deviceBrowser start];
    
    return self;
}

- (void) dealloc
{
    // Stop scanning for cameras
    [deviceBrowser stop];
}


/// Return the table of cameras
- (NSDictionary*) cameras
{
    return _cameras;
}


/// Return the count of changes
- (uint) changeCount
{
    return _changeCount;
}


#pragma mark ICDeviceBrowser delegate methods
/* This message is sent to the delegate when a device has been added.
    Adds the camera tot the table
 */
- (void)deviceBrowser:(ICDeviceBrowser*)browser
         didAddDevice:(ICDevice*) device
           moreComing:(BOOL)moreComing
{
    // Store the camera in the table
    _cameras[device.UUIDString] = device;
    // Increment our change count
    _changeCount++;
#if 0
    if ( addedDevice.type & ICDeviceTypeCamera )
    {
        addedDevice.delegate = self;
        
		// This triggers KVO messages to AppController
		// to add the new camera object to the cameras array.
		[[self mutableArrayValueForKey:@"cameras"] addObject:addedDevice];
    }
#endif
}


/* The required delegate method didRemoveDevice will handle the removal of camera devices. This message is sent to
 the delegate to inform that a device has been removed.
 */
- (void)deviceBrowser:(ICDeviceBrowser*)browser
      didRemoveDevice:(ICDevice*)device
            moreGoing:(BOOL)moreGoing
{
    /// Remove any delegate from the device
    device.delegate = NULL;
    
    // Remove the camera from the table
    [_cameras removeObjectForKey: device.UUIDString];
    // Increment our change count
    _changeCount++;
}



@end
