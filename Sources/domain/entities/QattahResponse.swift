//
//  QattahResponse.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Foundation

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public class QattahResponse : Decodable, ObservableObject {
    
    var successful: Bool?
    var data: QattahData?
    var links: QattahLinks?
    
}
