//
//  HelperProtocal.swift
//  HideMyMac
//
//  Created by Joubin Jabbari on 2/20/16.
//  Copyright © 2016 Joubin Jabbari. All rights reserved.
//

import Foundation

@objc protocol HelperProtocol {
    init()
    
    func connectWithEndpointReply(reply:(NSXPCListenerEndpoint) -> Void)
    func getVersionWithReply(reply:(String) -> Void)
    func uninstall()
    func exitWithCode(exitCode: Int)
//    func processRequest(reply:(Bool) -> Void)
    func processRequest()
    
}

