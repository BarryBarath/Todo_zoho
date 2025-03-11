//
//  ReminderListCollectionViewCell.swift
//  ToDoList
//
//  Created by develop on 05/03/25.
//

import UIKit

class ReminderListCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var propertyiconView: UIView!
    @IBOutlet weak var propertyImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        propertyiconView.applyRoundedCorners()
        containerView.cornerRadius(radius: 8)
        
        titleLabel.font = UIFont.customFont(size: 16, weight: .medium)
        countLabel.font = UIFont.customFont(size: 16, weight: .medium)
    }

}
