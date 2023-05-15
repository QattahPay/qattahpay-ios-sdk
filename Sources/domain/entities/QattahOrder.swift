//
//  QattahOrder.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Foundation

public struct QattahOrder : Decodable, Hashable {
    
    var id :String?
    var merchantId: String?
    var merchantName:String?
    var reference: String?
    var amount: String?
    var startedAt: String?
    var isExpired: Bool?
    var isTimedOut: Bool?
    var activityStatus: String?
    var paymentStatus: String?
    var callbackUrl: String?
    
}
