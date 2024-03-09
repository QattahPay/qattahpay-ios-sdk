//
//  ApiError.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 09/03/2024.
//

import Foundation

public enum ApiError: Error {
    case invalidUrl
    case invalidResponse
    case noResponse
    case invalidData
    case unableToDecode
    case unableToComplete
}
