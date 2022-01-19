//
// Created by Andrés Boedo on 8/11/20.
// Copyright (c) 2020 Purchases. All rights reserved.
//

import Foundation
@testable import RevenueCat
import StoreKit

class MockProductsManager: ProductsManager {

    var invokedProducts = false
    var invokedProductsCount = 0
    var invokedProductsParameters: Set<String>?
    var invokedProductsParametersList = [(identifiers: Set<String>, Void)]()
    var stubbedProductsCompletionResult: Set<StoreProduct>?

    override func products(withIdentifiers identifiers: Set<String>,
                           completion: @escaping (Result<Set<StoreProduct>, Error>) -> Void) {
        invokedProducts = true
        invokedProductsCount += 1
        invokedProductsParameters = identifiers
        invokedProductsParametersList.append((identifiers, ()))
        if let result = stubbedProductsCompletionResult {
            completion(.success(result))
        } else {
            let products: [StoreProduct] = identifiers
                .map { (identifier) -> MockSK1Product in
                    let product = MockSK1Product(mockProductIdentifier: identifier)
                    product.mockSubscriptionGroupIdentifier = "1234567"
                    if #available(iOS 11.2, tvOS 11.2, macOS 10.13.2, *) {
                        let mockDiscount = MockSKProductDiscount()
                        mockDiscount.mockIdentifier = "discount_id"
                        product.mockDiscount = mockDiscount
                    }
                    return product
                }
                .map(StoreProduct.init(sk1Product:))

            completion(.success(Set(products)))
        }
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.2, macOS 10.15, *)
    override func products(
        withIdentifiers identifiers: Set<String>
    ) async -> Set<StoreProduct> {
        invokedProducts = true
        invokedProductsCount += 1
        invokedProductsParameters = identifiers
        invokedProductsParametersList.append((identifiers, ()))
        return stubbedProductsCompletionResult ?? Set()
    }

    var invokedCacheProduct = false
    var invokedCacheProductCount = 0
    var invokedCacheProductParameter: SK1Product?

    override func cacheProduct(_ product: SK1Product) {
        invokedCacheProduct = true
        invokedCacheProductCount += 1
        invokedCacheProductParameter = product
    }

    func resetMock() {
        invokedProducts = false
        invokedProductsCount = 0
        invokedProductsParameters = nil
        invokedProductsParametersList = []
        stubbedProductsCompletionResult = nil
        invokedCacheProduct = false
        invokedCacheProductCount = 0
        invokedCacheProductParameter = nil
    }
}