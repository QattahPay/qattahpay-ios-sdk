// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI
import WebKit


@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class QattahPaySDK: ObservableObject {

    private var service: ApiService
    private var apiKey: String

    public init(apiKey: String) {
        self.apiKey = apiKey
        service = ApiService()
    }

    @available(iOS 13.0, *)
    public func startPaymentSession(paymentRequest: PaymentRequest, onSuccess: @escaping (_: QattahResponse) -> Void, onFail: @escaping (_ errorMessage: String) -> Void) {
        
        if (apiKey == "" || apiKey == "<YOUR_API_KEY>") {
            onFail("API KEY is required")
            return
        }
        
        if (paymentRequest.amount == nil) {
            onFail("Amount is required")
            return
        }
        
        if (paymentRequest.amount == 0) {
            onFail("Amount is zero")
            return
        }
        
        service.createNewQattahOrder(apiToken: self.apiKey, reference: "ref", paymentRequest: paymentRequest, isSandbox: paymentRequest.isSandbox ?? true, isTesting: paymentRequest.isTesting ?? false) { qattahResponse in
            qattahResponse.apiKey = self.apiKey
            qattahResponse.isSandbox = paymentRequest.isSandbox
            onSuccess(qattahResponse)
            
        } onError: { errorMessage in

            print(errorMessage)
            onFail(errorMessage)
            
        }
    }
}
