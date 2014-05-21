//
//  Camera.m
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

@implementation ThingInfo(Camera)
/**@brief Convert the device node into a structure 
   @param device  The camera/scanner device to convert
   @returns Dictionary of key/value pairs
*/
+ (NSDictionary*) cameraInfo: (ICDevice*) device
{
    NSMutableDictionary* ret = [[NSMutableDictionary alloc] init];
    
//    @abstract ￼Name of the device as reported by the device module or by the device transport when a device module is not in control of this device. This name may change if the device module overrides the default name of the device reported by the device's transport, or if the name of the filesystem volume mounted by the device is changed by the user.
    add(ret, @"name", device.name);

    // @abstract ￼Filesystem path of the device module that is associated with this device. Camera-specific capabilities are defined in ICCameraDevice.h and scanner-specific capabilities are defined in ICScannerDevice.h.
    add(ret, @"modulePath", device.modulePath);
    // ￼The bundle version of the device module associated with this device. This may change if an existing device module associated with this device is updated or a new device module for this device is installed.
    add(ret, @"moduleVersion", device.moduleVersion);
    
    // A string representation of the Universally Unique ID of the device.
    add(ret, @"UUID", device.UUIDString);
    
    // ￼A string representation of the persistent ID of the device.
    add(ret, @"persistentID", device.persistentIDString);

    // ￼A string object with one of the ICButtonType* values defined above.
    add(ret, @"buttonPressed", device.buttonPressed);
    
    // ￼Filesystem path of an application that is to be automatically launched when this device is added.
    add(ret, @"autolaunchApplicationPath", device.autolaunchApplicationPath);
    
    // ￼A mutable dictionary to store arbitrary key-value pairs associated with a device object. This can be used by view objects that bind to this object to store "house-keeping" information.
    add(ret, @"userData", device.userData);

    // ￼The transport type used by the device. The possible values are: ICTransportTypeUSB, ICTransportTypeFireWire, ICTransportTypeBluetooth, ICTransportTypeTCPIP, or ICTransportTypeMassStorage.
    add(ret, @"transportType", device.transportType);
    
    // ￼The serial number of the device. This will be NULL if the device does not provide a serial number.
    add(ret, @"serialNumberString", device.serialNumberString);

    // ￼A non-localized location description string for the device.
    // The value returned in one of the location description strings defined above, or location obtained from the Bonjour TXT record of a network device.
    add(ret, @"locationDescription", device.locationDescription);

    // ￼The capabilities of the device as reported by the device module.
    add(ret, @"capabilities", device.capabilities);

    // ￼The type of the device as defined by ICDeviceType OR'd with its ICDeviceLocationType. The type of this device can be obtained by AND'ing the value retuned by this property with an appropriate ICDeviceTypeMask. The location type of this device can be obtained by AND'ing the value retuned by this property with an appropriate ICDeviceLocationTypeMask.
    add(ret, @"type", device.type==ICDeviceTypeCamera?@"camera":device.type==ICDeviceTypeScanner?@"scanner":nil);

    // @abstract ￼Indicates whether the device has an open session.
    add(ret, @"hasOpenSession", device.hasOpenSession?@true:@false);

    // @abstract ￼Indicates whether the device is a remote device published by Image Capture device sharing facility.
    add(ret, @"remote", device.remote?@true:@false);
    // @abstract ￼Indicates whether the device is shared using the Image Capture device sharing facility. This value will change when sharing of this device is enabled or disabled.
    add(ret, @"shared", device.shared?@true:@false);
    //  ￼Indicates whether the device can be configured for use on a WiFi network.
    add(ret, @"hasConfigurableWiFiInterface", device.hasConfigurableWiFiInterface?@true:@false);

    // ￼The FireWire GUID of a FireWire device in the IOKit registry. This will be 0 for non-FireWire devices.
    if (device.fwGUID)
        add(ret, @"firewireGUID", [NSNumber numberWithLongLong: device.fwGUID]);

    // @abstract ￼The USB product ID of a USB device in the IOKit registry. This will be 0 for non-USB devices.
    if (device.usbProductID)
        add(ret, @"usbProductID", [NSNumber numberWithInt: device.usbProductID]);

#if 0
    /*!
     @property icon
     @abstract ￼Icon image for the device.
     
     */
    @property(readonly)                     CGImageRef            icon;
    
    /*!
     @property moduleExecutableArchitecture
     @abstract ￼Executable Architecture of the device module in control of this device. This is equal to a value as defined in NSBundle.h or CFBundle.h.
     
     */
    @property(readonly)                     int                   moduleExecutableArchitecture;
    
    /*!
     @property usbLocationID
     @abstract ￼The USB location ID of a USB device in the IOKit registry. This will be 0 for non-USB devices.
     
     */
    @property(readonly)                     int                   usbLocationID;
    
    
    /*!
     @property usbVendorID
     @abstract ￼The USB vendor ID of a USB device in the IOKit registry. This will be 0 for non-USB devices.
     
     */
    @property(readonly)                     int                   usbVendorID;
#endif
    
}


@end
