//
//  ReminderTableViewCell.swift
//  ToDoList
//
//  Created by develop on 05/03/25.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var reminderIcon: UIImageView!
    @IBOutlet weak var reminderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
