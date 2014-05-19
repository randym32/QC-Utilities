//
//  WLAN.m
//  QC Utilities
//
//  Created by Randall Maas on 5/19/14.
//
//

#import "WLAN.h"
#import <CoreWLAN/CoreWLAN.h>

@implementation WLAN
/* We need to declare the input / output properties as dynamic as Quartz Composer will handle their implementation */
@dynamic inputWLANid;


/// Holds the attributes for this plugin
static NSDictionary* portAttributes;
+ (void) initialize
{
    RegisterExceptionHandler();
    portAttributes =
    @{
      @"inputWLANid":
          @{
              QCPortAttributeNameKey: @"WLAN id",
              QCPortAttributeDefaultValueKey: @"",
              QCPortAttributeTypeKey: QCPortTypeString
            },
      };
}


+ (NSDictionary*) attributes
{
	/* Return the attributes of this plug-in */
    return @{
             QCPlugInAttributeNameKey       : @"WLAN",
             QCPlugInAttributeCopyrightKey  : @"Randall Maas (c) 2014",
             QCPlugInAttributeCategoriesKey : @[@"Utility/Network"],
             QCPlugInAttributeDescriptionKey: @"Returns the structure for a WLAN interface.\n\n"
             };
}

+ (NSDictionary*) attributesForPropertyPortWithKey:(NSString*)key
{
	/* Return the attributes for the plug-in property ports */
    return portAttributes[key];
}


+ (QCPlugInExecutionMode) executionMode
{
	/* This plug-in is a processor (it just processes and may change with time) */
	return kQCPlugInExecutionModeProcessor;
    //
}

+ (QCPlugInTimeMode) timeMode
{
    // Either idle or time base.  I'm going with timeBase
	return kQCPlugInTimeModeNone;
}

- (NSString*)stringForPHYMode:(CWPHYMode)phyMode
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

- (NSString*)stringForSecurityMode:(CWSecurity)securityMode
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

- (NSString*)stringForOpMode:(CWInterfaceMode)opMode
{
	switch (opMode)
	{
        default                     : return @"";
		case kCWInterfaceModeIBSS   : return @"IBSS";
		case kCWInterfaceModeStation: return @"Infrastructure";
		case kCWInterfaceModeHostAP : return @"Host Access Point";
	}
}




/** @brief This method is called by Quartz Composer whenever the plug-in needs to recompute its result
 @param context
 @param time
 @param arguments
 */
- (BOOL) execute:(id<QCPlugInContext>)context
          atTime:(NSTimeInterval)time
   withArguments:(NSDictionary*)arguments
{
    if (![self didValueForInputKeyChange:@"inputWLANid"] && time )
        return YES;
    CWInterface* interface = [CWInterface interfaceWithName: self.inputWLANid];
    if (!interface)
    {
        self.outputStructure= @{};
        return YES;
    }

    self . outputStructure =
        @{
            // The BSD name
            @"WLAN id": [interface interfaceName],
            // The hardware media access control (MAC) address for the interface, returned as a UTF-8 string.
            @"MAC"    : [interface hardwareAddress],
            // The interface has its corresponding hardware attached.
            @"deviceAttached": [interface deviceAttached] ? @true:@false,
            // The interface has its corresponding network service enabled.
            @"active"        : [interface serviceActive] ? @true : @false,
            
          
          //-- dynamic items
            // The interface power state is set to "ON".
            @"powerOn"     : interface . powerOn ? @true : @false,
            // The current service set identifier (SSID) for the interface,
            @"SSID"        : interface . ssid,
            //  The current basic service set identifier (BSSID) for the interface, returned as a UTF-8 string.
            @"BSSID"       : interface . bssid,
            //   The current country code (ISO/IEC 3166-1:1997) for the interface.
            @"countryCode"     : interface . countryCode,
            // The current active PHY modes for the interface.
            @"phyMode"         : [self stringForPHYMode: interface . activePHYMode],
            // The current aggregate received signal strength indication (RSSI) measurement (dBm) for the interface.
            @"RSSI"            : [NSNumber numberWithInteger: interface . rssiValue],
            // The current aggregate noise measurement (dBm) for the interface.
            @"noiseMeasurement": [NSNumber numberWithInteger: interface . noiseMeasurement],
            // The current transmit power (mW) for the interface.
            @"transmitPower"   : [NSNumber numberWithInteger: interface . transmitPower],
            // The current transmit rate (Mbps) for the interface.
            @"transmitRate"    : [NSNumber numberWithDouble: interface . transmitRate],
            // The current security mode for the interface.
            @"security"        : [self stringForSecurityMode: interface . security],
            // The current mode for the interface.
            @"interfaceMode"   : [self stringForOpMode: interface . interfaceMode],
         };
    return YES;
    
	return YES;
}


@end

