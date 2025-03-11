//
//  ReminderSearchViewController.swift
//  ToDoList
//
//  Created by develop on 09/03/25.
//

import UIKit
import MapKit

enum ViewControllerType {
    case search
    case other
    case agenda
}

protocol AddressfetchProtocol {
    func fetchAddress(address: String)
}

class ReminderSearchViewController: UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var cancelLabel: UILabel!
    @IBOutlet weak var doneLabel: UILabel!
    
    @IBOutlet weak var dateFilterAppliedView: UIView!
    @IBOutlet weak var priorityFillterAppliedView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backBtn: UIView!
    @IBOutlet weak var topView: UIStackView!
    @IBOutlet weak var searchView: UISearchBar!
    @IBOutlet weak var calenderIconView: UIView!
    @IBOutlet weak var priorityIconView: UIView!
    @IBOutlet weak var searchTableView: UITableView!
    
    @IBOutlet weak var nodataLabel: UILabel!
    @IBOutlet weak var priorityVw: UIView!
    @IBOutlet weak var lowLabel: UILabel!
    @IBOutlet weak var mediumLabel: UILabel!
    @IBOutlet weak var highLabel: UILabel!
    @IBOutlet weak var filterIconView: UIView!
    
    var viewControllerType : ViewControllerType = .other
    var allReminders : [ToDoItem] = [ToDoItem]()
    var filteredReminders: [ToDoItem] = []
    var textField : UITextField!
    var addressFetcherdelegate : AddressfetchProtocol!
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults: [MKLocalSearchCompletion] = []
    var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setHandler()
        setupUI()
    }
    
    func setupUI() {
        
        [priorityIconView, calenderIconView].forEach { cornerView in
            cornerView?.applyRoundedCorners()
        }
        
        calendarView.cornerRadius(radius: 10)
        
        searchView.delegate = self
        searchTableView.register(UINib(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: "ReminderTableViewCell")
        
        [lowLabel, highLabel, mediumLabel].forEach { labels in
            labels?.font = UIFont.customFont(size: 14, weight: .medium)
        }
        
        [priorityFillterAppliedView, dateFilterAppliedView].forEach { roundViews in
            roundViews?.applyRoundedCorners()
        }
        
        priorityVw.clipsToBounds = true
        priorityVw.cornerRadius(radius: 10)
        
        titleLabel.font = UIFont.customFont(size: 20, weight: .bold)
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
        filterIconView.isHidden = viewControllerType == .search ? true : false
    }
    
    func setHandler() {
        backBtn.addTap { [unowned self] in
            switch viewControllerType {
            case .search:
                dismiss(animated: true)
            case .other, .agenda:
                navigationController?.popViewController(animated: true)
            }
        }
        
        view.addTap { [unowned self] in
            [calendarView, priorityVw].forEach { views in
                views?.isHidden = true
            }
        }
        
        priorityIconView.addTap {
            self.calenderIconView.isHidden = true
            self.priorityVw.isHidden = false
        }
        
        lowLabel.addTap { [unowned self] in
            priorityFillterAppliedView.isHidden = false
            filteredReminders = allReminders.filter { $0.prority.lowercased().contains(lowLabel.text!.lowercased()) }
            self.priorityVw.isHidden = true
            searchTableView.reloadData()
        }
        
        mediumLabel.addTap { [unowned self] in
            priorityFillterAppliedView.isHidden = false
            filteredReminders = allReminders.filter { $0.prority.lowercased().contains(mediumLabel.text!.lowercased()) }
            self.priorityVw.isHidden = true
            searchTableView.reloadData()
        }
        
        highLabel.addTap { [unowned self] in
            priorityFillterAppliedView.isHidden = false
            filteredReminders = allReminders.filter { $0.prority.lowercased().contains(highLabel.text!.lowercased()) }
            self.priorityVw.isHidden = true
            searchTableView.reloadData()
        }
        
        calenderIconView.addTap { [unowned self] in
            priorityVw.isHidden = true
            datePicker.datePickerMode = .date
            datePicker.preferredDatePickerStyle = .wheels
            calendarView.isHidden = false
            datePicker.addTarget(self, action: #selector(dateChanged(_ :)), for: .valueChanged)
        }
        
        doneLabel.addTap { [self] in
            calendarView.isHidden = true
            let selectedDate = selectedDate
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.string(from: selectedDate)
            filterReminders(for: formatter.date(from: date) ?? Date())
        }
        
        cancelLabel.addTap {
            self.calendarView.isHidden = true
        }
    }

    @objc func dateChanged(_ sender: UIDatePicker) {
        dateFilterAppliedView.isHidden = false
        selectedDate = sender.date
    }
    
    func filterReminders(for selectedDate: Date) {
        let calendar = Calendar.current
        
        filteredReminders = allReminders.filter { reminder in
            return calendar.isDate(reminder.due_date, inSameDayAs: selectedDate)
        }
        searchTableView.reloadData()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if viewControllerType == .search {
            searchCompleter.queryFragment = searchText
        } else {
            if searchText.isEmpty {
                filteredReminders = allReminders
            } else {
                filteredReminders = allReminders.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            }
        }
        searchTableView.reloadData()
    }

}

extension ReminderSearchViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error fetching autocomplete results: \(error.localizedDescription)")
    }
}


extension ReminderSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewControllerType == .search {
            if searchResults.isEmpty {
                nodataLabel.isHidden = false
                searchTableView.isHidden = true
            } else {
                nodataLabel.isHidden = true
                searchTableView.isHidden = false
            }
            return searchResults.count
        } else {
            if filteredReminders.isEmpty {
                nodataLabel.isHidden = false
                searchTableView.isHidden = true
            } else {
                nodataLabel.isHidden = true
                searchTableView.isHidden = false
            }
            return filteredReminders.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell") as! ReminderTableViewCell
        if viewControllerType == .search {
            cell.reminderLabel.text = searchResults[indexPath.row].title + searchResults[indexPath.row].subtitle
            cell.reminderIcon.image = UIImage.geoFenceIcon()
        } else {
            cell.reminderLabel.text = filteredReminders[indexPath.row].title
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewControllerType == .search {
            addressFetcherdelegate.fetchAddress(address: searchResults[indexPath.row].title + searchResults[indexPath.row].subtitle)
            self.dismiss(animated: true)
        } else {
            let vc = ReminderDetailViewController.instantiate(fromStoryboard: .main)
            vc.reminderTodoItem = filteredReminders[indexPath.row]
            vc.reminderActionType = .update
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
