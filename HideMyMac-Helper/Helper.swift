//
//  Helper.swift
//  HideMyMac
//
//  Created by Joubin Jabbari on 2/20/16.
//  Copyright © 2016 Joubin Jabbari. All rights reserved.
//


import Foundation
import MachO.fat
import MachO.loader

extension NSURL {
    func hasExtendedAttribute(attribute: String) -> Bool {
        return getxattr(self.path!, attribute, nil, 0, 0, XATTR_NOFOLLOW) != -1
    }
    
    var isProtected : Bool {
        return hasExtendedAttribute("com.apple.rootless")
    }
}

final class Helper : NSObject, NSXPCListenerDelegate {
    
    private var listener: NSXPCListener
    private var timer: NSTimer?
    private let timeoutInterval = NSTimeInterval(30.0)
    private let workerQueue = NSOperationQueue()
    

    
    override init() {
        listener = NSXPCListener(machServiceName: HideMyMacHelperClient.ident)
        
        super.init()
        
        listener.delegate = self
        workerQueue.maxConcurrentOperationCount = 1
    }
    
    func run() {
        print("HideMyMac-Helper started")
        
        listener.resume()
        timer = NSTimer.scheduledTimerWithTimeInterval(timeoutInterval, target: self, selector: "timeout:", userInfo: nil, repeats: false)
        
        NSRunLoop.currentRunLoop().run()
    }
    
    @objc func timeout(_: NSTimer) {
        NSLog("timeout while waiting for request")
        exitWithCode(Int(EXIT_SUCCESS))
    }
    
    func connectWithEndpointReply(reply:(NSXPCListenerEndpoint) -> Void) {
        reply(listener.endpoint)
    }
    
    var version: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
    }
    
    func getVersionWithReply(reply:(String) -> Void) {
        reply(version)
    }
    
    // see https://devforums.apple.com/message/1004420#1004420
    func uninstall() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath("/Library/PrivilegedHelperTools/"+HideMyMacHelperClient.ident)
            try NSFileManager.defaultManager().removeItemAtPath("/Library/LaunchDaemons/"+HideMyMacHelperClient.ident+".plist")
        } catch _ {
        }
    }
    
    func exitWithCode(exitCode: Int) {
        NSLog("exiting with exit status \(exitCode)")
        workerQueue.waitUntilAllOperationsAreFinished()
        exit(Int32(exitCode))
    }
    
    func processRequest(reply:(Bool) -> Void) {
        timer?.invalidate()
        
           workerQueue.addOperationWithBlock {
                // do the work here
            reply(true)
        }
    }
    
    //MARK: - NSXPCListenerDelegate
    
    func listener(listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
//        let interface = NSXPCInterface(withProtocol: HelperProtocol.self)
//        let helperRequestClass = HelperRequest.self as AnyObject as! NSObject
//        let classes = Set([helperRequestClass])
//        interface.setClasses(classes, forSelector: "processRequest:progress:reply:", argumentIndex: 0, ofReply: false)
//        interface.setInterface(NSXPCInterface(withProtocol: ProgressProtocol.self), forSelector: "processRequest:progress:reply:", argumentIndex: 1, ofReply: false)
//        newConnection.exportedInterface = interface
//        newConnection.exportedObject = self
//        newConnection.resume()
//        
//        return true
        newConnection.exportedInterface = NSXPCInterface(withProtocol: HelperProtocol.self)
        let exportedObject = Helper()
        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
    

    
    func hasCodeSignature(url: NSURL) -> Bool {
        var codeRef: SecStaticCode?
        let result = SecStaticCodeCreateWithPath(url, .DefaultFlags, &codeRef)
        if result == errSecSuccess, let codeRef = codeRef {
            var requirement: SecRequirement?
            let result2 = SecCodeCopyDesignatedRequirement(codeRef, .DefaultFlags, &requirement)
            return result2 == errSecSuccess
        }
        return false
    }

}
