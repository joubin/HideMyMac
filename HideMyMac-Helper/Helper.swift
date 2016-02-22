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
    
    var version: String {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleVersion") as! String
    }
    
    override init() {
        listener = NSXPCListener(machServiceName: "io.jabbari.HideMyMac.HideMyMac-Helper")
        
        super.init()
        
        listener.delegate = self
        workerQueue.maxConcurrentOperationCount = 1
    }
    
    func run() {
        NSLog("HideMyMac-Helper started")
        
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
    
    func getVersionWithReply(reply:(String) -> Void) {
        reply(version)
    }
    
    // see https://devforums.apple.com/message/1004420#1004420
    func uninstall() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath("/Library/PrivilegedHelperTools/io.jabbari.HideMyMac.HideMyMac-Helper")
            try NSFileManager.defaultManager().removeItemAtPath("/Library/LaunchDaemons/io.jabbari.HideMyMac.HideMyMac-Helper.plist")
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
        
        
        //NSLog("Received request: %@", request)
        
        // https://developer.apple.com/library/mac/releasenotes/Foundation/RN-Foundation/#10_10NSXPC
//        let progress = NSProgress(totalUnitCount: -1)
//        progress.completedUnitCount = 0
//        progress.cancellationHandler = {
//            NSLog("Stopping HideMyMac-Helper")
//        }
//        context.progress = progress
//        context.remoteProgress = remoteProgress
//        
        // check if /usr/bin/strip is present
//        request.doStrip = request.doStrip && context.fileManager.fileExistsAtPath("/usr/bin/strip")
        
        workerQueue.addOperationWithBlock {
                // do the work here
            reply(true)
        }
    }
    
    //MARK: - NSXPCListenerDelegate
    
    func listener(listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
//        let interface = NSXPCInterface(withProtocol: HelperProtocol.self)
////        let helperRequestClass = HelperRequest.self as AnyObject as! NSObject
////        let classes = Set([helperRequestClass])
////        interface.setClasses(classes, forSelector: "processRequest:progress:reply:", argumentIndex: 0, ofReply: false)
//        interface.setInterface(NSXPCInterface(withProtocol: ProgressProtocol.self), forSelector: "processRequest:progress:reply:", argumentIndex: 1, ofReply: false)
//        newConnection.exportedInterface = interface
//        newConnection.exportedObject = self
//        newConnection.resume()
//        
//        return true

        newConnection.exportedInterface = NSXPCInterface(withProtocol: HelperProtocol.self)
  //      let exportedObject = XPCService()
//        newConnection.exportedObject = exportedObject
        newConnection.resume()
        return true
    }
    
    //MARK: -
    
//    private func iterateDirectory(url: NSURL, context:HelperContext, prefetchedProperties:[String], block:(NSURL, NSDirectoryEnumerator) -> Void) {
//        if let progress = context.progress where progress.cancelled {
//            return
//        }
//        
//        if context.isExcluded(url) || context.isDirectoryBlacklisted(url) || url.isProtected {
//            return
//        }
//        
//        context.addCodeResourcesToBlacklist(url)
//        
//        if let dirEnumerator = context.fileManager.enumeratorAtURL(url, includingPropertiesForKeys:prefetchedProperties, options:[], errorHandler:nil) {
//            for entry in dirEnumerator {
//                if let progress = context.progress where progress.cancelled {
//                    return
//                }
//                let theURL = entry as! NSURL
//                
//                var isDirectory: AnyObject?
//                do {
//                    try theURL.getResourceValue(&isDirectory, forKey:NSURLIsDirectoryKey)
//                } catch _ {
//                }
//                
//                if let isDirectory = isDirectory as? Bool where isDirectory {
//                    if context.isExcluded(theURL) || context.isDirectoryBlacklisted(theURL) || theURL.isProtected {
//                        dirEnumerator.skipDescendents()
//                        continue
//                    }
//                    context.addCodeResourcesToBlacklist(theURL)
//                }
//                
//                block(theURL, dirEnumerator)
//            }
//        }
//    }
//    
//    func processDirectory(url: NSURL, context:HelperContext) {
//        iterateDirectory(url, context:context, prefetchedProperties:[NSURLIsDirectoryKey]) { theURL, dirEnumerator in
//            var isDirectory: AnyObject?
//            do {
//                try theURL.getResourceValue(&isDirectory, forKey:NSURLIsDirectoryKey)
//            } catch _ {
//            }
//            
//            if let isDirectory = isDirectory as? Bool where isDirectory {
//                if let lastComponent = theURL.lastPathComponent, directories = context.request.directories {
//                    if directories.contains(lastComponent) {
//                        context.remove(theURL)
//                        dirEnumerator.skipDescendents()
//                    }
//                }
//            }
//        }
//    }
//    
//    func thinFile(url: NSURL, context: HelperContext, lipo: Lipo) {
//        var sizeDiff: Int = 0
//        if lipo.run(url.path!, sizeDiff: &sizeDiff) {
//            if sizeDiff > 0 {
//                context.reportProgress(url, size:sizeDiff)
//            }
//        }
//    }
//    
//    func thinDirectory(url: NSURL, context:HelperContext, lipo: Lipo) {
//        iterateDirectory(url, context:context, prefetchedProperties:[NSURLIsDirectoryKey,NSURLIsRegularFileKey,NSURLIsExecutableKey]) { theURL, dirEnumerator in
//            do {
//                let resourceValues = try theURL.resourceValuesForKeys([NSURLIsRegularFileKey, NSURLIsExecutableKey])
//                if let isExecutable = resourceValues[NSURLIsExecutableKey] as? Bool, isRegularFile = resourceValues[NSURLIsRegularFileKey] as? Bool where isExecutable && isRegularFile && !context.isFileBlacklisted(theURL) {
//                    let data = try NSData(contentsOfURL:theURL, options:([.DataReadingMappedAlways, .DataReadingUncached]))
//                    var magic: UInt32 = 0
//                    if data.length >= sizeof(UInt32) {
//                        data.getBytes(&magic, length: sizeof(UInt32))
//                        
//                        if let pathExtension = theURL.pathExtension where pathExtension == "class" {
//                            return
//                        }
//                        if magic == FAT_MAGIC || magic == FAT_CIGAM {
//                            self.thinFile(theURL, context:context, lipo: lipo)
//                        }
//                        if context.request.doStrip && (magic == FAT_MAGIC || magic == FAT_CIGAM || magic == MH_MAGIC || magic == MH_CIGAM || magic == MH_MAGIC_64 || magic == MH_CIGAM_64) {
//                            self.stripFile(theURL, context:context)
//                        }
//                    }
//                }
//            } catch _ {
//            }
//        }
//    }
    
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
    
//    func stripFile(url: NSURL, context:HelperContext) {
//        // do not modify executables with code signatures
//        if !hasCodeSignature(url) {
//            do {
//                let attributes = try context.fileManager.attributesOfItemAtPath(url.path!)
//                let path = url.path!
//                var size: AnyObject?
//                do {
//                    try url.getResourceValue(&size, forKey:NSURLTotalFileAllocatedSizeKey)
//                } catch _ {
//                    try! url.getResourceValue(&size, forKey:NSURLFileAllocatedSizeKey)
//                }
//                
//                let oldSize = size as! Int
//                
//                let task = NSTask.launchedTaskWithLaunchPath("/usr/bin/strip", arguments:["-u", "-x", "-S", "-", path])
//                task.waitUntilExit()
//                
//                if task.terminationStatus != EXIT_SUCCESS {
//                    NSLog("/usr/bin/strip failed with exit status %d", task.terminationStatus)
//                }
//                
//                let newAttributes = [
//                    NSFileOwnerAccountID : attributes[NSFileOwnerAccountID]!,
//                    NSFileGroupOwnerAccountID : attributes[NSFileGroupOwnerAccountID]!,
//                    NSFilePosixPermissions : attributes[NSFilePosixPermissions]!
//                ]
//                
//                do {
//                    try context.fileManager.setAttributes(newAttributes, ofItemAtPath:path)
//                } catch let error as NSError {
//                    NSLog("Failed to set file attributes for '%@': %@", path, error)
//                }
//                do {
//                    try url.getResourceValue(&size, forKey:NSURLTotalFileAllocatedSizeKey)
//                } catch _ {
//                    try! url.getResourceValue(&size, forKey:NSURLFileAllocatedSizeKey)
//                }
//                let newSize = size as! Int
//                if oldSize > newSize {
//                    let sizeDiff = oldSize - newSize
//                    context.reportProgress(url, size:sizeDiff)
//                }
//            } catch let error as NSError {
//                NSLog("Failed to get file attributes for '%@': %@", url, error)
//            }
//        }
//    }
}
