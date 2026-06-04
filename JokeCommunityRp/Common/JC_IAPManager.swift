//
//  JC_IAPManager.swift
//  JokeCommunityRp
//
//  Created by  mac on 2026/6/4.
//

import Foundation
import StoreKit

enum JC_IAPError: LocalizedError {
    case productNotFound
    case userCancelled
    case pending
    case verificationFailed
    case notLoggedIn

    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not available. Please try again later."
        case .userCancelled:
            return nil
        case .pending:
            return "Purchase is pending approval."
        case .verificationFailed:
            return "Purchase verification failed."
        case .notLoggedIn:
            return "Please sign in before purchasing."
        }
    }
}

@MainActor
final class JC_IAPManager {

    static let shared = JC_IAPManager()

    private var storeProducts: [String: Product] = [:]
    private var updatesTask: Task<Void, Never>?
    private var processedTransactionIds: Set<UInt64> = []

    private enum Keys {
        static let processedTransactions = "jc_processedIAPTransactions"
    }

    private init() {
        loadProcessedTransactionIds()
        updatesTask = Task { [weak self] in
            await self?.listenForTransactionUpdates()
        }
    }

    deinit {
        updatesTask?.cancel()
    }

    func displayPrice(for productId: String) -> String? {
        storeProducts[productId]?.displayPrice
    }

    func loadProducts() async throws -> [JC_CoinProduct] {
        let storeItems = try await Product.products(for: JC_CoinCatalog.productIds)
        storeProducts = Dictionary(uniqueKeysWithValues: storeItems.map { ($0.id, $0) })

        return JC_CoinCatalog.products.map { item in
            var product = item
            product.storePrice = storeProducts[item.productId]?.displayPrice
            return product
        }
    }

    @discardableResult
    func purchase(productId: String) async throws -> Int {
        guard JC_CurrentUser.shared.isLoggedIn else {
            throw JC_IAPError.notLoggedIn
        }

        guard let product = storeProducts[productId] else {
            throw JC_IAPError.productNotFound
        }

        let diamondCount = JC_CoinCatalog.diamondCount(for: productId)
        guard diamondCount > 0 else {
            throw JC_IAPError.productNotFound
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            grantDiamonds(diamondCount, for: transaction)
            await transaction.finish()
            return diamondCount
        case .userCancelled:
            throw JC_IAPError.userCancelled
        case .pending:
            throw JC_IAPError.pending
        @unknown default:
            throw JC_IAPError.verificationFailed
        }
    }

    private func listenForTransactionUpdates() async {
        for await update in Transaction.updates {
            do {
                let transaction = try checkVerified(update)
                let diamondCount = JC_CoinCatalog.diamondCount(for: transaction.productID)
                guard diamondCount > 0 else {
                    await transaction.finish()
                    continue
                }
                await MainActor.run {
                    self.grantDiamonds(diamondCount, for: transaction)
                }
                await transaction.finish()
            } catch {
                continue
            }
        }
    }

    private func grantDiamonds(_ amount: Int, for transaction: Transaction) {
        guard markTransactionProcessed(transaction.id) else { return }
        JC_CurrentUser.shared.addCoins(amount)
    }

    private func markTransactionProcessed(_ transactionId: UInt64) -> Bool {
        guard !processedTransactionIds.contains(transactionId) else { return false }
        processedTransactionIds.insert(transactionId)
        saveProcessedTransactionIds()
        return true
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw JC_IAPError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    private func loadProcessedTransactionIds() {
        guard let strings = UserDefaults.standard.array(forKey: Keys.processedTransactions) as? [String] else {
            return
        }
        processedTransactionIds = Set(strings.compactMap { UInt64($0) })
    }

    private func saveProcessedTransactionIds() {
        UserDefaults.standard.set(
            processedTransactionIds.map { String($0) },
            forKey: Keys.processedTransactions
        )
    }
}
