import Foundation
import SuperwallKit
import RevenueCat

let purchaseController = SubscriptionController()

private enum PurchasingError: LocalizedError {
    case sk2ProductNotFound
    
    var errorDescription: String? {
        switch self {
        case .sk2ProductNotFound:
            return "Superwall didn't pass a StoreKit 2 product to purchase. Are you sure you're not "
            + "configuring Superwall with a SuperwallOption to use StoreKit 1?"
        }
    }
}


final class SubscriptionController: PurchaseController  {
    // MARK: Sync Subscription Status
    /// Makes sure that Superwall knows the customer's entitlements by
    /// changing `Superwall.shared.entitlements`
    func syncSubscriptionStatus() {
        assert(Purchases.isConfigured, "You must configure RevenueCat before calling this method.")
        Task {
            for await customerInfo in Purchases.shared.customerInfoStream {
                // Gets called whenever new CustomerInfo is available
                let superwallEntitlements = customerInfo.entitlements.activeInCurrentEnvironment.keys.map {
                    Entitlement(id: $0)
                }
                await MainActor.run { [superwallEntitlements] in
                    Superwall.shared.subscriptionStatus = .active(Set(superwallEntitlements))
                    GlobalState.shared.isProUser = Superwall.shared.subscriptionStatus.isActive
                }
            }
        }
    }
    
    // MARK: Handle Purchases
    /// Makes a purchase with RevenueCat and returns its result. This gets called when
    /// someone tries to purchase a product on one of your paywalls.
    func purchase(product: SuperwallKit.StoreProduct) async -> PurchaseResult {
        do {
            guard let sk2Product = product.sk2Product else {
                throw PurchasingError.sk2ProductNotFound
            }
            let storeProduct = RevenueCat.StoreProduct(sk2Product: sk2Product)
            let revenueCatResult = try await Purchases.shared.purchase(product: storeProduct)
            if revenueCatResult.userCancelled {
                return .cancelled
            } else {
                GlobalState.shared.isProUser = true
                
                switch sk2Product.id {
                case "com.face.ai.weekly":
                    GlobalState.shared.credits += 200
                case "com.face.ai.monthly":
                    GlobalState.shared.credits += 1000
                default:
                    break
                }
                
                return .purchased
            }
        } catch let error as ErrorCode {
            if error == .paymentPendingError {
                return .pending
            } else {
                return .failed(error)
            }
        } catch {
            return .failed(error)
        }
    }
    
    // MARK: Handle Restores
    /// Makes a restore with RevenueCat and returns `.restored`, unless an error is thrown.
    /// This gets called when someone tries to restore purchases on one of your paywalls.
    func restorePurchases() async -> RestorationResult {
        do {
            let customerInfo = try await Purchases.shared.restorePurchases()
            let entitlements = customerInfo.entitlements.active
            
            GlobalState.shared.isProUser = !entitlements.isEmpty
            
            var alreadyRestoredIds = UserDefaults.standard.array(forKey: "restoredProductIds") as? [String] ?? []
            
            for (_, entitlement) in entitlements {
                let productId = entitlement.productIdentifier
                
                if !alreadyRestoredIds.contains(productId) {
                    switch productId {
                    case "com.face.ai.weekly":
                        try? await UserApi.shared.addCredits(200)
                        GlobalState.shared.credits += 200
                    case "com.face.ai.monthly":
                        try? await UserApi.shared.addCredits(1000)
                        GlobalState.shared.credits += 1000
                    default:
                        break
                    }
                    
                    alreadyRestoredIds.append(productId)
                }
            }
            
            // Save updated restored product IDs
            UserDefaults.standard.set(alreadyRestoredIds, forKey: "restoredProductIds")
            
            return .restored
        } catch {
            return .failed(error)
        }
    }
}
