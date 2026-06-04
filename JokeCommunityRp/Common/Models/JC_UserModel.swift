//
//  JC_UserModel.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/3.
//

import UIKit

enum JC_UserGender {
    case male
    case female

    var iconName: String {
        switch self {
        case .male:
            return "profile_male"
        case .female:
            return "profile_female"
        }
    }

    var displayName: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        }
    }
}

struct JC_UserModel {

    var userId: String
    var nickname: String
    var gender: JC_UserGender
    var age: Int
    var bio: String
    var friendCount: Int
    var likeCount: Int
    var coinCount: Int
    var avatar: UIImage?
    var email: String
    var password: String
    var isBlock: Bool
    var followingUserIds: [String]

    var ageText: String {
        "\(age)"
    }

    var friendCountText: String {
        "\(friendCount)"
    }

    var likeCountText: String {
        likeCount > 999 ? "999+" : "\(likeCount)"
    }

    func isFollowing(userId: String) -> Bool {
        followingUserIds.contains(userId)
    }

    /// 仅用于未登录时的占位；已登录请使用 `JC_CurrentUser.shared.user`
    static var current: JC_UserModel {
        JC_CurrentUser.shared.user ?? JC_UserData.testUser
    }

    static var loggedInUser: JC_UserModel? {
        JC_CurrentUser.shared.user
    }

}
