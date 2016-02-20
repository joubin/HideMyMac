//
//  HideMyMac_XPCService.h
//  HideMyMac-XPCService
//
//  Created by Joubin Jabbari on 2/20/16.
//  Copyright © 2016 Joubin Jabbari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HideMyMac_XPCServiceProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface HideMyMac_XPCService : NSObject <HideMyMac_XPCServiceProtocol>
@end
