//
//  ReminderHeaderTableViewCell.swift
//  ToDoList
//
//  Created by develop on 08/03/25.
//

import UIKit

class ReminderHeaderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reminderCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.customFont(size: 16, weight: .medium)
        reminderCountLabel.font = UIFont.customFont(size: 16, weight: .medium)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
