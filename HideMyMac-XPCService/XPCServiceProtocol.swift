//
//  XPCServiceProtocol.swift
//  HideMyMac
//
//  Created by Joubin Jabbari on 2/20/16.
//  Copyright © 2016 Joubin Jabbari. All rights reserved.
//

import Foundation
import XPC

@objc protocol XPCServiceProtocol {
    func bundledHelperVersion(reply:(String) -> Void)
    func installHelperTool(withReply:(NSError?) -> Void)
    func connect(withReply:(NSXPCListenerEndpoint?) -> Void)
    func capital(string:NSString, reply:(NSString?)->Void)
}
