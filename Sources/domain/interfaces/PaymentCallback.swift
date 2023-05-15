//
//  PaymentCallback.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Foundation

public protocol PaymentCallback {
    
    func onStarted(paymentId: String)
    func onSuccess(paymentId: String)
    func onError(errorMessage: String)
    func onCancel()
    
}
