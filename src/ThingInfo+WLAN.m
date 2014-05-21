//
//  DevInfo+WLAN.m
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

static NSString* stringForPHYMode(CWPHYMode phyMode)
{
	switch (phyMode)
	{
		case kCWPHYMode11a: return @"802.11a";
		case kCWPHYMode11b: return @"802.11b";
		case kCWPHYMode11g: return @"802.11g";
		case kCWPHYMode11n:	return @"802.11n";
        case kCWPHYMode11ac:return @"802.11ac";
	}
	return @"";
}

static NSString* stringForSecurityMode(CWSecurity securityMode)
{
	switch (securityMode)
	{
        default                         : return @"Unknown";
		case kCWSecurityNone            : return @"";
		case kCWSecurityWEP             : return @"WEP";
		case kCWSecurityWPAPersonal     : return @"WPA Personal";
		case kCWSecurityWPAPersonalMixed: return @"WPA/WPA2 Personal";
		case kCWSecurityWPA2Personal    : return @"WPA2 Personal";
		case kCWSecurityWPAEnterprise   : return @"WPA Enterprise";
		case kCWSecurityWPAEnterpriseMixed: return @"WPA Enterprise";
		case kCWSecurityWPA2Enterprise  : return @"WPA2 Enterprise";
        case kCWSecurityDynamicWEP      : return @"Dynamic WEP";
	}
}

static NSString* stringForOpMode(CWInterfaceMode opMode)
{
	switch (opMode)
	{
        default                     : return @"";
		case kCWInterfaceModeIBSS   : return @"IBSS";
		case kCWInterfaceModeStation: return @"Infrastructure";
		case kCWInterfaceModeHostAP : return @"Host Access Point";
	}
}





@implementation ThingInfo (WLAN)
/**@brief Convert the device node into a structure
   @param itnerface  The WLAN device to convert
   @returns Dictionary of key/value pairs
*/
+ (NSDictionary*) wlanInfo: (CWInterface*) interface
{
    if (!interface)
        return @{};
    return
        @{
            @"type"  : @"wlan",
            // The BSD name
            @"WLAN id": [interface interfaceName],
            // The hardware media access control (MAC) address for the interface.
            @"MAC"    : [interface hardwareAddress],
            // The interface has its corresponding hardware attached.
            @"deviceAttached": [interface deviceAttached] ? @true:@false,
            // The interface has its corresponding network service enabled.
            @"active"        : [interface serviceActive] ? @true : @false,
            
          
          //-- dynamic items
            // The interface power state is set to "ON".
            @"powerEnabed"   : interface . powerOn ? @true : @false,
            // The current service set identifier (SSID) for the interface,
            @"SSID"          : interface . ssid,
            //  The current basic service set identifier (BSSID) for the interface.
            @"BSSID"           : interface . bssid,
            //   The current country code (ISO/IEC 3166-1:1997) for the interface.
            @"countryCode"     : interface . countryCode,
            // The current active PHY modes for the interface.
            @"phyMode"         :  stringForPHYMode(interface . activePHYMode),
            // The current aggregate received signal strength indication (RSSI) measurement (dBm) for the interface.
            @"RSSI"            : [NSNumber numberWithInteger: interface . rssiValue],
            // The current aggregate noise measurement (dBm) for the interface.
            @"noiseMeasurement": [NSNumber numberWithInteger: interface . noiseMeasurement],
            // The current transmit power (mW) for the interface.
            @"transmitPower"   : [NSNumber numberWithInteger: interface . transmitPower],
            // The current transmit rate (Mbps) for the interface.
            @"transmitRate"    : [NSNumber numberWithDouble: interface . transmitRate],
            // The current security mode for the interface.
            @"security"        :  stringForSecurityMode(interface . security),
            // The current mode for the interface.
            @"interfaceMode"   :  stringForOpMode(interface . interfaceMode),
         };
}
@end
