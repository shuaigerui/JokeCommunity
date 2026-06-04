//
//  JC_FriendItem.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import UIKit

struct JC_FriendItem {
    let userId: String
    let name: String
    let avatar: UIImage?
}

struct JC_FriendSection {
    let title: String
    let items: [JC_FriendItem]
}
