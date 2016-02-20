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


    @IBAction func takeText(sender: AnyObject) {
        self.textLabel.stringValue = self.textField.stringValue;
    }
}

