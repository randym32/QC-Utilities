//
//  WLAN.h
//  QC Utilities
//
//  Created by Randall Maas on 5/19/14.
//
//

#import "QCUtils.h"

@interface WLAN : QCPlugIn
/* Declare a property input port of type "String" and with the key "inputWLANid"
   The identifier for the WLAN
 */
@property(assign) NSString* inputWLANid;

@property(assign) NSDictionary* outputStructure;

@end
