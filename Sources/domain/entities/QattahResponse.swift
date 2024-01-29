//
//  QattahResponse.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Foundation

@available(iOS 13.0, *)
public class QattahResponse : Decodable, ObservableObject {
    
    var successful: Bool?
    var data: QattahData?
    var links: QattahLinks?
    var apiKey: String?
    
}
