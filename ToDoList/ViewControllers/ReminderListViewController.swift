//
//  ReminderListViewController.swift
//  ToDoList
//
//  Created by develop on 05/03/25.
//

import UIKit

class ReminderListViewController: UIViewController, UISearchBarDelegate {
    
   
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var searchContentView: UIView!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reminderView: UIView!
    @IBOutlet weak var reminderIconView: UIView!
    @IBOutlet weak var myListTitleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var reminderLabel: UILabel!
    
    var reminderListModel = [ReminderListModel]()
    var reminders: [ReminderStatusType: [ToDoItem]] = [:]
    var allReminders : [ToDoItem] = [ToDoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setActionHandler()
    }
    
    func configureUI() {
        reminderIconView.applyRoundedCorners()
        reminderView.cornerRadius(radius: 8)
        searchView.cornerRadius(radius: 8)
        searchContentView.cornerRadius(radius: 10)
        
        let todayCount = reminders[.today]?.count ?? 0
        let scheduleCount = (reminders[.tomorrow]?.count ?? 0) + (reminders[.upcoming]?.count ?? 0)
        let completedCount = reminders[.completed]?.count ?? 0
        let overdueCount = reminders[.overdue]?.count ?? 0
        
        allReminders = reminders.flatMap { $0.value }
        print("reminder Value::", allReminders)

        let totalCount = todayCount + scheduleCount + completedCount + overdueCount

        reminderListModel = [
            ReminderListModel(propertyImage: .todayCalendarIcon(), propertyname: "Today", propertyCounts: "\(todayCount)", propertyColor: .link),
            ReminderListModel(propertyImage: .scheduledCalendarIcon(), propertyname: "Scheduled", propertyCounts: "\(scheduleCount)", propertyColor: .red),
            ReminderListModel(propertyImage: .reminderALLIcon(), propertyname: "All", propertyCounts: "\(totalCount)", propertyColor: .black),
            ReminderListModel(propertyImage: .overdurIcon(), propertyname: "Overdue", propertyCounts: "\(overdueCount)", propertyColor: .orange),
            ReminderListModel(propertyImage: .tickIcon(), propertyname: "Completed", propertyCounts: "\(completedCount)", propertyColor: .darkGray)
        ]
        
        myListTitleLabel.font =  UIFont.customFont(size: 20, weight: .bold)
        reminderLabel.font = UIFont.customFont(size: 18, weight: .medium)
        titleLabel.font = UIFont.customFont(size: 20, weight: .bold)
        countLabel.font = UIFont.customFont(size: 16, weight: .medium)
        
        countLabel.text = "\(totalCount)"
    }
    
    func setActionHandler() {
        reminderView.addTap {
            let reminderViewController = ReminderViewController.instantiate(fromStoryboard: .main)
            self.navigationController?.pushViewController(reminderViewController, animated: true)
        }
        
        searchView.addTap {
            let reminderSearchViewController = ReminderSearchViewController.instantiate(fromStoryboard: .main)
            reminderSearchViewController.allReminders = self.allReminders
            self.navigationController?.pushViewController(reminderSearchViewController, animated: true)
        }
    }
}


extension ReminderListViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reminderListModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReminderListCollectionViewCell", for: indexPath) as! ReminderListCollectionViewCell
        cell.propertyImage.image = reminderListModel[indexPath.row].propertyImage
        cell.titleLabel.text = reminderListModel[indexPath.row].propertyname
        cell.countLabel.text = reminderListModel[indexPath.row].propertyCounts
        cell.propertyiconView.backgroundColor = reminderListModel[indexPath.row].propertyColor
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            if let items = reminders[.today] {
                reminderSearchFunc(todoItem: items)
            }
        case 1:
            if let tomorrowItems = reminders[.tomorrow],
               let upcomingItems = reminders[.upcoming] {
                let mergedItems = tomorrowItems + upcomingItems
                reminderSearchFunc(todoItem: mergedItems)
            }
        case 2:
            let reminderSearchViewController = ReminderSearchViewController.instantiate(fromStoryboard: .main)
            reminderSearchViewController.allReminders = self.allReminders
            self.navigationController?.pushViewController(reminderSearchViewController, animated: true)
        case 3:
            if let items = reminders[.overdue] {
                reminderSearchFunc(todoItem: items)
            }
        case 4:
            if let items = reminders[.completed] {
                reminderSearchFunc(todoItem: items)
            }
        default: break
        }
    }
    
    func reminderSearchFunc(todoItem: [ToDoItem]) {
        let searchViewController = ReminderSearchViewController.instantiate(fromStoryboard: .main)
        searchViewController.filteredReminders = todoItem
        self.navigationController?.pushViewController(searchViewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = ((collectionView.frame.width - 10) / 2)
        return CGSize(width: width, height: 90)
    }
}
