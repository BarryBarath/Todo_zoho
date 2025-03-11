//
//  UIView+Ext.swift
//  ToDoList
//
//  Created by develop on 06/03/25.
//

import Foundation
import UIKit

extension UIView {
    
    func makeToast(message: String, duration: TimeInterval = 3.0) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textAlignment = .center
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.font = UIFont.systemFont(ofSize: 14.0)
        toastLabel.layer.cornerRadius = 10.0
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 0
      
        let maxSize = CGSize(width: self.frame.size.width - 40, height: self.frame.size.height)
        let expectedSize = toastLabel.sizeThatFits(maxSize)
        toastLabel.frame = CGRect(x: (self.frame.size.width - expectedSize.width) / 2, y: self.frame.size.height - 100, width: expectedSize.width + 20, height: expectedSize.height + 10)
        
        self.addSubview(toastLabel)
        
        toastLabel.alpha = 0.0
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        }
    }
    
    func applyRoundedCorners() {
        self.layer.cornerRadius = self.frame.width / 2
    }
    
    func cornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
    }
    
    func addTap(action: @escaping () -> Void) {
        let tapGesture = CustomTapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.action = action
        tapGesture.numberOfTapsRequired = 1
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }
    
    @objc private func handleTap(_ sender: CustomTapGestureRecognizer) {
        sender.action?()
    }
}


class CustomTapGestureRecognizer: UITapGestureRecognizer {
    var action: (() -> Void)?
}
