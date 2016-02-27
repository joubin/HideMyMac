//
//  ViewController.swift
//  HideMyMac
//
//  Created by Joubin Jabbari on 2/20/16.
//  Copyright © 2016 Joubin Jabbari. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var textLabel: NSTextField!
    @IBOutlet weak var textField: NSTextField!
    
    private var helperConnection : NSXPCConnection?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private lazy var xpcServiceConnection: NSXPCConnection = {
        let connection = NSXPCConnection(serviceName: "io.jabbari.HideMyMac.HideMyMac-XPCService")
        connection.remoteObjectInterface = NSXPCInterface(withProtocol:XPCServiceProtocol.self)
        connection.resume()
        return connection
    }()
    
    @IBAction func takeText(sender: AnyObject) {
//        self.textLabel.stringValue = self.textField.stringValue;
        let xpcService = self.xpcServiceConnection.remoteObjectProxyWithErrorHandler() { error -> Void in
            NSLog("XPCService error: %@", error)
            } as? XPCServiceProtocol
//        var str:(NSString?)->Void = "A" as Void
//        xpcService?.capital(self.textField.stringValue, reply:{str:NSString}->{})
        xpcService?.capital(self.self.textField.stringValue, reply: { (str) -> Void in
            self.textLabel.stringValue = str as! String

        })
    }
    
    @IBAction func installHelperButton(sender: AnyObject) {
//        do {
//            try HideMyMacHelperClient.installWithPrompt("Hello")
//        } catch _ {
//
//        }
//        return
//        self.installHelper { (result) -> Void in
//            print("The result of running the installer %@", result);
//        }
        
        self.checkAndRunHelper()
    }
    
    

    private func checkAndRunHelper() {
        let xpcService = self.xpcServiceConnection.remoteObjectProxyWithErrorHandler() { error -> Void in
            NSLog("XPCService error: %@", error)
            } as? XPCServiceProtocol
        
        if let xpcService = xpcService {
            xpcService.connect() { endpoint -> Void in
                if let endpoint = endpoint {
                    var performInstallation = false
                    let connection = NSXPCConnection(listenerEndpoint: endpoint)
                    let interface = NSXPCInterface(withProtocol:HelperProtocol.self)
//                    interface.setInterface(NSXPCInterface(withProtocol: ProgressProtocol.self), forSelector: "processRequest:progress:reply:", argumentIndex: 1, ofReply: false)
                    connection.remoteObjectInterface = interface
                    connection.invalidationHandler = {
                        NSLog("XPC connection to helper invalidated.")
                        self.helperConnection = nil
                        if performInstallation {
                            self.installHelper() { success in
                                if success {
                                    self.checkAndRunHelper()
                                }
                            }
                        }
                    }
                    connection.resume()
                    self.helperConnection = connection
                    
                    if let connection = self.helperConnection {
                        let helper = connection.remoteObjectProxyWithErrorHandler() { error in
                            NSLog("Error connecting to helper: %@", error)
                            } as! HelperProtocol
                        
                        helper.getVersionWithReply() { installedVersion in
                            xpcService.bundledHelperVersion() { bundledVersion in
                                if installedVersion == bundledVersion {
                                    // helper is current
                                    dispatch_async(dispatch_get_main_queue()) {
                                        self.runHelper()
                                    }
                                } else {
                                    // helper is different version
                                    performInstallation = true
                                    helper.uninstall()
                                    helper.exitWithCode(Int(EXIT_SUCCESS))
                                    connection.invalidate()
                                }
                            }
                        }
                    }
                } else {
                    NSLog("Failed to get XPC endpoint.")
                    self.installHelper() { success in
                        if success {
                            self.checkAndRunHelper()
                        }
                    }
                }
            }
        }
    }
    
    
    func installHelper(reply:(Bool) -> Void) {
        let xpcService = self.xpcServiceConnection.remoteObjectProxyWithErrorHandler() { error -> Void in
            NSLog("XPCService error: %@", error)
            } as? XPCServiceProtocol
        
        if let xpcService = xpcService {
            xpcService.installHelperTool { error in
                if let error = error {
                    dispatch_async(dispatch_get_main_queue()) {
                        let alert = NSAlert()
                        alert.alertStyle = .CriticalAlertStyle
                        alert.messageText = error.localizedDescription
                        alert.beginSheetModalForWindow(self.view.window!, completionHandler: nil)
                    }
                    print(false)
                    reply(false)
                } else {
                    reply(true)
                    print(!false)
                }
            }
        }else{
            print("nothing")
        }
    }
    
    
    private func runHelper() {
        NSProcessInfo.processInfo().disableSuddenTermination()
        
        let progress = NSProgress(totalUnitCount: -1)
        progress.becomeCurrentWithPendingUnitCount(-1)
        progress.addObserver(self, forKeyPath: "completedUnitCount", options: .New, context: nil)
        
        // DEBUG
        //arguments.dryRun = true
        
        let helper = helperConnection!.remoteObjectProxyWithErrorHandler() { error in
            NSLog("Error communicating with helper: %@", error)
            dispatch_async(dispatch_get_main_queue()) {
//                self.finishProcessing()
                print("finished processing")
            }
            } as! HelperProtocol
        
        helper.processRequest()
        
    
        
        let notification = NSUserNotification()
        notification.title = NSLocalizedString("Monolingual started", comment:"")
        notification.informativeText = NSLocalizedString("Started removing files", comment:"")
        
        NSUserNotificationCenter.defaultUserNotificationCenter().deliverNotification(notification)
    }
    

    
    
   
}

