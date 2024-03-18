//
//  PaymentStatus.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 02/03/2024.
//

import Foundation

public enum PaymentStatus: String, Decodable {
    case PENDING = "PENDING"
    case EXPIRED = "EXPIRED"
    case PAID = "PAID"
    case AUTHORIZED = "AUTHORIZED"
    case REFUNDED = "REFUNDED"
}
