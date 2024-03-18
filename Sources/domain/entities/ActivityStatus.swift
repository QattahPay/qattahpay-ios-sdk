//
//  ActivityStatus.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 02/03/2024.
//

import Foundation

public enum ActivityStatus: String, Decodable {
    case CREATED = "CREATED"
    case STARTED = "STARTED"
    case PAID = "PAID"
    case TIMEOUT = "TIMEOUT"
    case ABANDONED = "ABANDONED"
    
}
