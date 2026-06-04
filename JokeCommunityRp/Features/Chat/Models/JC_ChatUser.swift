//
//  JC_ChatUser.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import UIKit

struct JC_ChatUser {
    let userId: String
    let name: String
    let avatar: UIImage?
}

struct JC_ChatMessage {
    let peerUserId: String
    let userName: String
    let preview: String
    let avatar: UIImage?
}
