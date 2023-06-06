//
//  PaymentRequest.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Foundation

public class PaymentRequestBuilder {
    
    public init() {
        
    }
    
    public private(set) var paymentRequest = PaymentRequest()
    
    public func setAmount(_ amount: Double) -> PaymentRequestBuilder {
        paymentRequest.amount = amount
        return self
    }
    public func setCurrency(_ currency: Currency) -> PaymentRequestBuilder {
        paymentRequest.currency = currency
        return self
    }
    public func setOrderId(_ orderId: String) -> PaymentRequestBuilder {
        paymentRequest.orderId = orderId
        return self
    }
    public func setDescription(_ description: String) -> PaymentRequestBuilder {
        paymentRequest.description = description
        return self
    }
    public func setCustomerEmail(_ emailAddress: String) -> PaymentRequestBuilder {
        paymentRequest.emailAddress = emailAddress
        return self
    }
    public func setCustomerMobileNumber(_ mobileNumber: String) -> PaymentRequestBuilder {
        paymentRequest.mobileNumber = mobileNumber
        return self
    }
    
    public func setLanguage(_ language: Language) -> PaymentRequestBuilder {
        paymentRequest.language = language
        return self
    }
    
    public func setTheme(_ theme: Theme) -> PaymentRequestBuilder {
        paymentRequest.theme = theme
        return self
    }
    
    public func isSandbox(_ isSandbox: Bool) -> PaymentRequestBuilder {
        paymentRequest.isSandbox = isSandbox
        return self
    }
    
    public func build() -> PaymentRequest {
        return self.paymentRequest
    }
}

public class PaymentRequest {
    
    var amount: Double?
    var currency: Currency?
    var orderId: String?
    var description: String?
    var emailAddress: String?
    var mobileNumber: String?
    var language: Language?
    var theme: Theme?
    var isSandbox: Bool?
    
}
