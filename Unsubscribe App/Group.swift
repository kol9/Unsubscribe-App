//
//  Group.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 29.10.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit
import Foundation


public struct Group {
    var name: String
    var id: Int
    var description: String
    var membersCount: Int
    var imageURL: String
    var isHidden: Int
    var friends: Int?
    var lastPost: Date?
    var deactivated: String?
    var image: UIImage?
}
