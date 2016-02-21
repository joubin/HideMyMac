//
//  HelperClient.swift
//  HideMyMac
//
//  Created by Joubin Jabbari on 2/20/16.
//  Copyright © 2016 Joubin Jabbari. All rights reserved.
//

import Foundation
import SMJobKit

final class HideMyMacHelperClient : Client {
    override class var serviceIdentifier: String {
        return "io.jabbari.HideMyMac.HideMyMac-Helper"
    }
}
