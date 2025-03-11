//
//  ReminderDetailViewController.swift
//  ToDoList
//
//  Created by develop on 06/03/25.
//

import UIKit
import MapKit

enum ReminderActionType {
    case create
    case update
}

class ReminderDetailViewController: UIViewController {
    
    // MARK: - Title & Description
    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    @IBOutlet weak var backBtnView: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    
    // MARK: - Date & Time
    @IBOutlet weak var dateTimeContainerView: UIView!
    @IBOutlet weak var dateSectionView: UIView!
    @IBOutlet weak var calendarIconContainerView: UIView!
    @IBOutlet weak var calenderSwitch: UISwitch!
    @IBOutlet weak var dateTitleLabel: UILabel!
    @IBOutlet weak var dateValueLabel: UILabel!
    @IBOutlet weak var datePickerView: UIDatePicker!
    
    @IBOutlet weak var timeSectionView: UIView!
    @IBOutlet weak var timeIconContainerView: UIView!
    @IBOutlet weak var timeSwitch: UISwitch!
    @IBOutlet weak var timeTitleLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var timePickerView: UIDatePicker!
    
    
    // MARK: - Location
    @IBOutlet weak var locationContainerView: UIView!
    @IBOutlet weak var locationIconContainerView: UIView!
    @IBOutlet weak var locationSwitch: UISwitch!
    @IBOutlet weak var locationTitleLabel: UILabel!
    
    @IBOutlet weak var locationSelectionView: UIView!
    
    @IBOutlet weak var currentLocationContainerView: UIView!
    @IBOutlet weak var currentLocationIconContainerView: UIView!
    
    @IBOutlet weak var customLocationContainerView: UIView!
    @IBOutlet weak var customLocationIconContainerView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    // MARK: - Priority & Status
    @IBOutlet weak var priorityStatusContainerView: UIView!
    @IBOutlet weak var priorityContainerView: UIView!
    @IBOutlet weak var priorityIconView: UIImageView!
    @IBOutlet weak var priorityLabel: UILabel!
    
    @IBOutlet weak var taskStatusContainerView: UIView!
    @IBOutlet weak var taskStatusIconView: UIImageView!
    @IBOutlet weak var taskStatusLabel: UILabel!

    @IBOutlet weak var deleteBtn: UIButton!
    
    var todoItemViewModel = ToDoItemViewModel()
    var reminderTodoItem = ToDoItem()
    var locationManager: CLLocationManager!
    var reminderActionType : ReminderActionType = .create
    var currentSelectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setActionHandler()
    }
    
    func configureUI() {
        
        datePickerView.datePickerMode = .date
        datePickerView.preferredDatePickerStyle = .inline
        
        timePickerView.datePickerMode = .time
        timePickerView.preferredDatePickerStyle = .wheels
        
        [calendarIconContainerView, timeIconContainerView, locationIconContainerView, currentLocationIconContainerView, customLocationIconContainerView].forEach({ $0?.applyRoundedCorners() })
        
        [titleContainerView, dateTimeContainerView, locationContainerView, priorityStatusContainerView].forEach({ commonView in
            commonView?.clipsToBounds = true
            commonView?.cornerRadius(radius: 8)
        })
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // Request location authorization
        locationManager.requestWhenInUseAuthorization()
        
        if reminderActionType == .update {
            setupUpdate()
            doneBtn.setTitle("Update", for: .normal)
            deleteBtn.isHidden = false
        } else {
            deleteBtn.isHidden = true
            doneBtn.setTitle("Done", for: .normal)
        }
        
        [dateTitleLabel, timeTitleLabel, locationTitleLabel].forEach { labels in
            labels?.font = UIFont.customFont(size: 18, weight: .medium)
        }
    }
    
    func setupUpdate() {
        print("render todoItems::", reminderTodoItem.time)
        datePickerView.date = reminderTodoItem.due_date
        let timeString = reminderTodoItem.time

        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        formatter.locale = Locale(identifier: "en_US_POSIX")

        if let timeDate = formatter.date(from: timeString) {
            timePickerView.date = timeDate
        }
        
        titleTextField.text = reminderTodoItem.title
        descriptionTextField.text = reminderTodoItem.descriptions
        dateValueLabel.text = dateConverterString(selectedDate: reminderTodoItem.due_date)
        timeValueLabel.text = reminderTodoItem.time
        locationLabel.text = reminderTodoItem.locations
        priorityLabel.text = reminderTodoItem.prority
        taskStatusLabel.text = reminderTodoItem.status
        
        calenderSwitch.isOn = true
        datePickerView.isHidden = false
        
        if !reminderTodoItem.time.isEmpty {
            timeSwitch.isOn = true
            timePickerView.isHidden = false
        }
        
        if reminderTodoItem.locations != "Location" {
            locationSwitch.isOn = true
            locationSelectionView.isHidden = false
        }
        
        if reminderTodoItem.prority == "High" {
            priorityIconView.tintColor = .red
        } else if reminderTodoItem.prority == "Medium" {
            priorityIconView.tintColor = .black
        } else {
            priorityIconView.tintColor = .link
        }
    }
    
    func setActionHandler() {
        calenderSwitch.addTarget(self, action: #selector(switchCalenderValueDidChange(_:)), for: .valueChanged)
        timeSwitch.addTarget(self, action: #selector(switchTimerValueDidChange(_:)), for: .valueChanged)
        locationSwitch.addTarget(self, action: #selector(switchLocationValueDidChange(_:)), for: .valueChanged)
        
        priorityContainerView.addTap { [unowned self] in
            presentReminderPopup(for: .priorityLevel)
        }
        
        taskStatusContainerView.addTap { [unowned self] in
            presentReminderPopup(for: .taskStatus)
        }
        
        backBtnView.addTap {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
        doneBtn.addTap { [unowned self] in
            if !titleTextField.text!.isEmpty {
                createTodoItem()
            }
        }
        
        deleteBtn.addTap {
            self.deleteTodoItem()
        }
        
        datePickerView.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        timePickerView.addTarget(self, action: #selector(timeChanged), for: .valueChanged)
        
        currentLocationContainerView.addTap {
            self.locationManager.startUpdatingLocation()
        }
        
        customLocationContainerView.addTap {
            let locationSearchViewController = ReminderSearchViewController.instantiate(fromStoryboard: .main)
            locationSearchViewController.viewControllerType = .search
            locationSearchViewController.addressFetcherdelegate = self
            self.navigationController?.present(locationSearchViewController, animated: true)
        }
    }
    
    @objc func dateChanged(sender: UIDatePicker) {
        let selectedDate = sender.date
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = formatter.string(from: selectedDate)
        currentSelectedDate = formatter.date(from: date) ?? Date()
        dateValueLabel.text = date
    }
    
    @objc func timeChanged(sender: UIDatePicker) {
        let selectedTime = sender.date
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        let timeString = formatter.string(from: selectedTime)
        timeValueLabel.text = timeString
    }
    
    func presentReminderPopup(for popupType: ReminderPopupType) {
        let reminderPopupVc = ReminderPopupViewController.instantiate(fromStoryboard: .main)
        reminderPopupVc.currentPopupType = popupType
        reminderPopupVc.parsedStrg = (popupType == .priorityLevel ? priorityLabel.text : taskStatusLabel.text) ?? ""
        reminderPopupVc.reminderDelegate = self
        navigationController?.present(reminderPopupVc, animated: true)
    }
    
    func createTodoItem() {
        var todoItem = ToDoItem()
        todoItem.title = titleTextField.text!
        todoItem.descriptions = descriptionTextField.text!
        todoItem.due_date = currentSelectedDate
        todoItem.locations = locationLabel.text!
        todoItem.prority = priorityLabel.text!
        todoItem.id = reminderActionType == .create ? UUID().uuidString : reminderTodoItem.id
        todoItem.status = taskStatusLabel.text!
        todoItem.time = timeValueLabel.text!
        switch reminderActionType {
        case .create:
            todoItemViewModel.createToDoItem(todoItem)
            todoItemViewModel.onCreateToDoItemSuccess = {
                self.view.makeToast(message: "Todo Listing Created")
            }
        case .update:
            todoItemViewModel.updateToDoItem(todoItem)
            todoItemViewModel.onUpdateToDoItemSuccess = {
                self.view.makeToast(message: "Todo Listing Updated")
            }
        }
        todoItemViewModel.todoerrorHandler = {}
    }
    
    func deleteTodoItem() {
        var deleteTodo = ToDoItem()
        deleteTodo.id = reminderTodoItem.id
        todoItemViewModel.deleteToDoItem(deleteTodo)
        todoItemViewModel.onDeleteToDoItemSuccess = {
            self.view.makeToast(message: "Todo Listing Deleted")
            self.navigationController?.popViewController(animated: true)
        }
        todoItemViewModel.todoerrorHandler = {}
    }
}

extension ReminderDetailViewController : ReminderDataDelegate, CLLocationManagerDelegate, AddressfetchProtocol {
    func fetchAddress(address: String) {
        locationLabel.text = address
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation = locations.first {
            _ = currentLocation.coordinate.latitude
            _ = currentLocation.coordinate.longitude
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
                if let error = error {
                    print("Error reverse geocoding: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    let address = "\(placemark.name ?? "N/A"), \(placemark.locality ?? "N/A"), \(placemark.administrativeArea ?? "N/A"), \(placemark.country ?? "N/A")"
                    print("Full Address: \(address)")
                    self.locationLabel.text = address
                }
            }
        }
    }
    
    func didReceiveReminderData(reminderItem: String, for popupType: ReminderPopupType, selectedIndex: Int) {
        switch popupType {
        case .priorityLevel:
            priorityLabel.text = reminderItem
            priorityIconView.tintColor = selectedIndex == 0 ? .red : selectedIndex == 1 ? .black : .blue
        case .taskStatus:
            taskStatusLabel.text = reminderItem
            taskStatusLabel.textColor = selectedIndex == 0 ? .blue : selectedIndex == 1 ? .green : .red
        }
    }

    @objc func switchCalenderValueDidChange(_ sender: UISwitch) {
        datePickerView.isHidden = sender.isOn ? false : true
     }
    
    @objc func switchTimerValueDidChange(_ sender: UISwitch) {
        timePickerView.isHidden = sender.isOn ? false : true
     }
    
    @objc func switchLocationValueDidChange(_ sender: UISwitch) {
        locationSelectionView.isHidden = sender.isOn ? false : true
     }
}
