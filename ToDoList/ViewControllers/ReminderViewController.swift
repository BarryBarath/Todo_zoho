//
//  ReminderViewController.swift
//  ToDoList
//
//  Created by develop on 05/03/25.
//

import UIKit
import CoreLocation
import UserNotifications

enum ReminderStatusType {
    case today, tomorrow, completed, overdue, upcoming
}

struct ReminderStatus {
    let title: String
    var isSelected: Bool
    let statusType: ReminderStatusType
}

class ReminderViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var noReminderLabel: UILabel!
    
    private var reminderStatusHeadings: [ReminderStatus] = []
    private var todoItemViewModel = ToDoItemViewModel()
    private var reminders: [ReminderStatusType: [ToDoItem]] = [:]
    
    let locationManager = CLLocationManager()
    var geofenceRegionCenter = CLLocationCoordinate2D()
    let geofenceRadius: CLLocationDistance = 500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setActionHandlers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchToDoItems()
    }
    
    private func configureUI() {
        reminderStatusHeadings = [
            ReminderStatus(title: "Today", isSelected: false, statusType: .today),
            ReminderStatus(title: "Tomorrow", isSelected: false, statusType: .tomorrow),
            ReminderStatus(title: "Completed", isSelected: false, statusType: .completed),
            ReminderStatus(title: "Overdue", isSelected: false, statusType: .overdue),
            ReminderStatus(title: "Upcoming", isSelected: false, statusType: .upcoming)
        ]
        tableView.register(UINib(nibName: "ReminderTableViewCell", bundle: nil), forCellReuseIdentifier: "ReminderTableViewCell")
        tableView.register(UINib(nibName: "ReminderHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "ReminderHeaderTableViewCell")
        addView.cornerRadius(radius: 8)
        
        titleLabel.font = UIFont.customFont(size: 22, weight: .bold)
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization() // Always allow for background tracking
        locationManager.startUpdatingLocation()
        
        setupGeofence()
        requestNotificationPermission()
    }
    
    private func setActionHandlers() {
        addView.addTap { [weak self] in
            guard let self = self else { return }
            let vc = ReminderDetailViewController.instantiate(fromStoryboard: .main)
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        menuView.addTap { [weak self] in
            guard let self = self else { return }
            let vc = ReminderListViewController.instantiate(fromStoryboard: .main)
            vc.reminders = reminders
            self.pushWithRightToLeftTransition(vc)
        }
    }
    
    private func fetchToDoItems() {
        todoItemViewModel.fetchToDoItems()
        todoItemViewModel.onFetchToDoItemsSuccess = { [weak self] data in
            guard let self = self else { return }
            scheduleReminderIfDueToday(data: data, hour: 8, minute: 0)
            
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
            
            self.reminders = [.today: [], .tomorrow: [], .completed: [], .overdue: [], .upcoming: []]
            
            data.forEach { item in
                self.getCoordinates(for: item.locations) { locations, error in
                    self.geofenceRegionCenter = CLLocationCoordinate2D(latitude: locations?.latitude ?? 0.0, longitude: locations?.longitude ?? 0.0)
                }
                let dueDate = item.due_date
                if item.status == "Completed" {
                    self.reminders[.completed]?.append(item)
                } else if dueDate < today {
                    self.reminders[.overdue]?.append(item)
                } else if calendar.isDate(dueDate, inSameDayAs: today) {
                    self.reminders[.today]?.append(item)
                } else if calendar.isDate(dueDate, inSameDayAs: tomorrow) {
                    self.reminders[.tomorrow]?.append(item)
                } else {
                    self.reminders[.upcoming]?.append(item)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func scheduleReminderIfDueToday(data: [ToDoItem], hour: Int, minute: Int) {
        let calendar = Calendar.current
        let now = Date()
        
        let today = calendar.startOfDay(for: now)
        
        // Check if any item's due_date is today
        let hasDueToday = data.contains { item in
            let dueDate = calendar.startOfDay(for: item.due_date)
            return dueDate == today
        }
        
        if hasDueToday {
            print("A task is due today. Scheduling notification...")
            scheduleDailyMorningNotification(hour: hour, minute: minute)
        } else {
            print("No tasks due today. No notification needed.")
        }
    }
}

//GeoFence and Setup for Map with Local notification

extension ReminderViewController: CLLocationManagerDelegate {
    func setupGeofence() {
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter, radius: geofenceRadius, identifier: "MonitoredRegion")
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        locationManager.startMonitoring(for: geofenceRegion)
    }
    
    func getCoordinates(for address: String, completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let location = placemarks?.first?.location {
                completion(location.coordinate, nil)
            } else {
                completion(nil, NSError(domain: "GeocodingError", code: 0, userInfo: [NSLocalizedDescriptionKey: "No coordinates found"]))
            }
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    self.sendLocalNotification(title: "Welcome!", body: "You have entered the area.")
                } else {
                    print("Permission denied: \(error?.localizedDescription ?? "No error info")")
                }
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("Entered the geofence area")
        sendLocalNotification(title: "Welcome!", body: "You have entered the area.")
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("Exited the geofence area")
        sendLocalNotification(title: "Alert!", body: "You have left the area.")
    }

    func sendLocalNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification Error: \(error)")
            }
        }
    }
    
    func scheduleDailyMorningNotification(hour: Int, minute: Int) {
        // Get today's date components
        let calendar = Calendar.current
        let now = Date()
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        var scheduleDate = calendar.date(from: components)
        
        if let scheduledDate = scheduleDate, scheduledDate <= now {
            components.day! += 1
            scheduleDate = calendar.date(from: components) ?? Date()
        }
        
        // Create a trigger that repeats daily
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create the content for the notification
        let content = UNMutableNotificationContent()
        content.title = "Good Morning!"
        content.body = "Today is the last day! Don't forget your task."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "dailyMorningReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily morning notification: \(error)")
            } else {
                print(":x: :white_check_mark: Daily morning notification scheduled!")
            }
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension ReminderViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reminderStatusHeadings.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let heading = reminderStatusHeadings[section]
        return heading.isSelected ? reminders[heading.statusType]?.count ?? 0 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "ReminderHeaderTableViewCell") as! ReminderHeaderTableViewCell
        
        let heading = reminderStatusHeadings[section]
        headerCell.titleLabel.text = heading.title
        headerCell.reminderCountLabel.text = "\(reminders[heading.statusType]?.count ?? 0)"
        headerCell.titleLabel.textColor = heading.isSelected ? .link : .black
        
        headerCell.containerView.addTap { [weak self] in
            guard let self = self else { return }
            self.reminderStatusHeadings[section].isSelected.toggle()
            self.tableView.reloadData()
        }
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderTableViewCell", for: indexPath) as! ReminderTableViewCell
        let heading = reminderStatusHeadings[indexPath.section]
        
        if let items = reminders[heading.statusType] {
            cell.reminderLabel.text = items[indexPath.row].title.capitalized
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ReminderDetailViewController.instantiate(fromStoryboard: .main)
        if let items = reminders[reminderStatusHeadings[indexPath.section].statusType] {
            vc.reminderTodoItem = items[indexPath.row]
        }
        vc.reminderActionType = .update
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
