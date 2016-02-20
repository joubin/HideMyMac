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
        let connection = NSXPCConnection(serviceName: "io.jabbari.HideMyMac-XPCService")
        connection.remoteObjectInterface = NSXPCInterface(withProtocol:XPCServiceProtocol.self)
        connection.resume()
        print("asd")
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
}

