//
//  File.swift
//  
//
//  Created by khlafawi on 06/06/2023.
//

import Foundation

public enum Language: CustomStringConvertible {
    
    case EN
    case AR
    
    public var description : String {
       switch self {
       case .EN: return "en"
       case .AR: return "ar"
       }
     }
}
