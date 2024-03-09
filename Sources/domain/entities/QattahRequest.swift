//
//  QattahRequest.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 01/03/2024.
//

import Foundation

public struct QattahRequest : Encodable, Hashable {
    
    public let amount: Double
    public let reference: String?
    public let callback_url: String = "https://testing-callback.qattahpay.sa"
    public let theme: Theme?
    public let lang: Language?
    public let currency: Currency?
    public let description: String?
    public let emailAddress: String?
    public let mobileNumber: String?
    var platform: String = "iOS"
    var version: String = "1.6.6"
    
    public init(amount: Double, reference: String?, theme: Theme?, lang: Language?, currency: Currency?, description: String?, emailAddress: String?, mobileNumber: String?) {
        self.amount = amount
        self.reference = reference ?? ""
        self.theme = theme ?? .LIGHT
        self.lang = lang ?? .AR
        self.currency = currency ?? .SAR
        self.description = description ?? ""
        self.emailAddress = emailAddress ?? ""
        self.mobileNumber = mobileNumber ?? ""
    }
}
