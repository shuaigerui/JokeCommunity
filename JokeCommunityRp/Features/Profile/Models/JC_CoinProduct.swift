//
//  JC_CoinProduct.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/2.
//

import Foundation

struct JC_CoinProduct {
    let productId: String
    let diamondCount: Int
    let fallbackPrice: String
    var storePrice: String?

    var coins: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: diamondCount)) ?? "\(diamondCount)"
    }

    var price: String {
        storePrice ?? fallbackPrice
    }
}

enum JC_CoinCatalog {

    static let products: [JC_CoinProduct] = [
        JC_CoinProduct(productId: "gawpsmiwlvkwcgix", diamondCount: 63700, fallbackPrice: "$99.99"),
        JC_CoinProduct(productId: "exnzlzarihipelra", diamondCount: 29400, fallbackPrice: "$49.99"),
        JC_CoinProduct(productId: "ockdkhfnhiweborw", diamondCount: 10800, fallbackPrice: "$19.99"),
        JC_CoinProduct(productId: "nhnjlbasvkxzusnk", diamondCount: 5150, fallbackPrice: "$9.99"),
        JC_CoinProduct(productId: "dxbfwkoqdeoinmdi", diamondCount: 2450, fallbackPrice: "$4.99"),
        JC_CoinProduct(productId: "aoxxnhpfejdzrvnt", diamondCount: 800, fallbackPrice: "$1.99"),
        JC_CoinProduct(productId: "gtncnmovpwicirtk", diamondCount: 400, fallbackPrice: "$0.99")
    ]

    static var productIds: Set<String> {
        Set(products.map(\.productId))
    }

    static func product(for productId: String) -> JC_CoinProduct? {
        products.first { $0.productId == productId }
    }

    static func diamondCount(for productId: String) -> Int {
        product(for: productId)?.diamondCount ?? 0
    }
}
