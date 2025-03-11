//
//  AppstoryBoards.swift
//  ToDoList
//
//  Created by develop on 08/03/25.
//

import Foundation
import UIKit

enum AppStoryboard: String {
    
    case main = "Main"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func ViewController<T: UIViewController>(vc: T.Type) -> T {
        let storyboard = (vc as UIViewController.Type).identifier
        return instance.instantiateViewController(withIdentifier: storyboard) as! T
    }
}
