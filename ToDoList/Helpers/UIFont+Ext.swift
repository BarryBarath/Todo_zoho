//
//  UIFont+Ext.swift
//  ToDoList
//
//  Created by develop on 09/03/25.
//

import Foundation
import UIKit

extension UIFont {
    
    enum FontWeight {
        case regular, medium, semibold, bold
        
        var systemWeight: UIFont.Weight {
            switch self {
            case .regular: return .regular
            case .medium: return .medium
            case .semibold: return .semibold
            case .bold: return .bold
            }
        }
    }
    
    static func customFont(size: CGFloat, weight: FontWeight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weight.systemWeight)
    }
}
