//
//  Currency.swift
//  qattahpay-ios-sdk
//
//  Created by khlafawi on 14/04/2023.
//

import Foundation

public enum Currency {
    case SAR
//    case USD,
//    case EUR,
//    case GBP,
//    case JPY,
//    case AUD,
//    case CAD,
//    case CHF,
//    case CNY,
//    case DKK,
//    case HKD,
//    case INR,
//    case KRW,
//    case MXN,
//    case MYR,
//    case NZD,
//    case NOK,
//    case PHP,
//    case RUB,
//    case SEK,
//    case SGD,
//    case THB,
//    case TRY,
//    case ZAR
    
    public var description : String {
       switch self {
       case .SAR: return "SAR"
       }
     }
}
