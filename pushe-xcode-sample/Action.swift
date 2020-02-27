//
//  Action.swift
//  pushe-xcode-sample
//
//  Created by Hector on 2/22/20.
//  Copyright © 2020 pushe. All rights reserved.
//

import Foundation

enum Action: String, CaseIterable {
    case ids = "IDs"
    case deviceRegistrationStatus = "Device registration status"
    case topic = "Topic"
    case tag = "Tag(name:value)"
    case event = "Event"
    case clear
}
