//
//  UIViewController+Ext.swift
//  ToDoList
//
//  Created by develop on 08/03/25.
//

import Foundation
import UIKit

extension UIViewController {
    
    class var identifier: String {
        return "\(self)"
    }
    
    static func instantiate(fromStoryboard storyboard: AppStoryboard) -> Self {
        return storyboard.ViewController(vc: self)
    }
    
    func pushWithRightToLeftTransition(_ viewController: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = .push
        transition.subtype = .fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(viewController, animated: false)
    }
    
    func dateConverter(selectedDate: Date) -> Date {
        let selectedDate = selectedDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = formatter.string(from: selectedDate)
        return formatter.date(from: date) ?? Date()
    }
    
    func dateConverterString(selectedDate: Date) -> String {
        let selectedDate = selectedDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = formatter.string(from: selectedDate)
        return date
    }
}
