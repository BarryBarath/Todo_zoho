//
//  ReminderPopupViewController.swift
//  ToDoList
//
//  Created by develop on 07/03/25.
//

enum ReminderPopupType {
    case priorityLevel
    case taskStatus
}

protocol ReminderDataDelegate {
    func didReceiveReminderData(reminderItem: String, for popupType: ReminderPopupType, selectedIndex: Int)
}

import UIKit

class ReminderPopupViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dismissalView: UIView!
    @IBOutlet weak var popupTableView: UITableView! 
    
    var reminderItems = [String]()
    var currentPopupType : ReminderPopupType = .priorityLevel
    var reminderDelegate: ReminderDataDelegate!
    var parsedStrg = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        configurData()
        setActionHandler()
    }
    
    func configurData() {
        
        popupTableView.register(UINib(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: "ReminderTableViewCell")
        
        switch currentPopupType {
        case .priorityLevel:
            titleLabel.text = "Priority"
            reminderItems = ["High", "Medium", "Low"]
        case .taskStatus:
            titleLabel.text = "Status"
            reminderItems = ["Open", "Completed", "Overdue"]
        }
        
        dismissalView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    func setActionHandler() {
        dismissalView.addTap {
            self.dismiss(animated: true)
        }
    }
}

extension ReminderPopupViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell") as! ReminderTableViewCell
        cell.accessoryType = (reminderItems[indexPath.row] == parsedStrg) ? .checkmark : .none
        cell.reminderLabel.text = reminderItems[indexPath.row]
        switch currentPopupType {
        case .priorityLevel:
            cell.reminderIcon.image = UIImage.priorityIcon()
            setupReminderCell(for: .priorityLevel, cellIndex: indexPath.row, cell: cell)
        case .taskStatus:
            cell.reminderIcon.image = UIImage.reminderRadioUnchecked()
            setupReminderCell(for: .taskStatus, cellIndex: indexPath.row, cell: cell)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        reminderDelegate.didReceiveReminderData(reminderItem: reminderItems[indexPath.row], for: currentPopupType, selectedIndex: indexPath.row)
        dismiss(animated: true)
    }
    
    func setupReminderCell(for PopupType: ReminderPopupType, cellIndex: Int, cell: ReminderTableViewCell) {
        switch cellIndex {
        case 0: cell.reminderIcon.tintColor =  PopupType == .priorityLevel ? .red : .blue
        case 1: cell.reminderIcon.tintColor =  PopupType == .priorityLevel ? .black : .green
        case 2: cell.reminderIcon.tintColor =  PopupType == .priorityLevel ? .blue : .red
        default: break
        }
    }
    
}

