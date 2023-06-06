//
//  File.swift
//  
//
//  Created by khlafawi on 06/06/2023.
//

import Foundation

public enum Theme: CustomStringConvertible {
    
    case DARK
    case LIGHT
    
    public var description : String {
       switch self {
       case .DARK: return "dark"
       case .LIGHT: return "light"
       }
     }
}
