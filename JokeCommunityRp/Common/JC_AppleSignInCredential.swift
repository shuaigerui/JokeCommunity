//
//  JC_AppleSignInCredential.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import Foundation

struct JC_AppleSignInCredential: Equatable {
    let userIdentifier: String
    let email: String?
    let fullName: String?

    var suggestedNickname: String {
        let trimmed = fullName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed
    }
}

enum JC_AppleSignInOutcome {
    case completed
    case needsProfileSetup(JC_AppleSignInCredential)
}
