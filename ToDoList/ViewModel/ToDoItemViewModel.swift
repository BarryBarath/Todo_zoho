//
//  ToDoItemViewModel.swift
//  ToDoList
//
//  Created by develop on 08/03/25.
//

import Foundation
import UIKit
import CoreData

class ToDoItemViewModel {
    
    var onFetchToDoItemsSuccess: (([ToDoItem]) -> ())?
    var todoerrorHandler: (() -> ())?
    
    var onCreateToDoItemSuccess: (() -> ())?
    var onUpdateToDoItemSuccess: (() -> ())?
    var onDeleteToDoItemSuccess: (() -> ())?
    
    private func fetchToDoItemsFromCoreData(withPredicate predicate: NSPredicate? = nil) -> [ToDoEntity]? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let manageContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ToDoEntity> = ToDoEntity.fetchRequest()
        fetchRequest.predicate = predicate
        
        do {
            return try manageContext.fetch(fetchRequest)
        } catch {
            return nil
        }
    }
    
    private func saveToCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let manageContext = appDelegate.persistentContainer.viewContext
        do {
            try manageContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Fetch To-Do Items
    func fetchToDoItems() {
        if let result = fetchToDoItemsFromCoreData() {
            let toDoItemModels = result.map {
                ToDoItem(
                    title: $0.title ?? "",
                    descriptions: $0.descriptions ?? "",
                    due_date: $0.due_date ?? Date(),
                    locations: $0.locations ?? "",
                    prority: $0.priority ?? "",
                    id: $0.id ?? "",
                    status: $0.status ?? "",
                    time: $0.time ?? ""
                )
            }
            DispatchQueue.main.async {
                self.onFetchToDoItemsSuccess?(toDoItemModels)
            }
        } else {
            DispatchQueue.main.async {
                self.todoerrorHandler?()
            }
        }
    }
    
    // MARK: - Create To-Do Item
    func createToDoItem(_ item: ToDoItem) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let manageContext = appDelegate.persistentContainer.viewContext
        let entityDescription = NSEntityDescription.entity(forEntityName: "ToDoEntity", in: manageContext)!
        let newToDoItem = NSManagedObject(entity: entityDescription, insertInto: manageContext)
        
        newToDoItem.setValue(item.title, forKey: "title")
        newToDoItem.setValue(item.descriptions, forKey: "descriptions")
        newToDoItem.setValue(item.due_date, forKey: "due_date")
        newToDoItem.setValue(item.locations, forKey: "locations")
        newToDoItem.setValue(item.prority, forKey: "priority")
        newToDoItem.setValue(item.id, forKey: "id")
        newToDoItem.setValue(item.status, forKey: "status")
        newToDoItem.setValue(item.time, forKey: "time")
        
        saveToCoreData()
        DispatchQueue.main.async {
            self.onCreateToDoItemSuccess?()
        }
    }
    
    // MARK: - Update To-Do Item
    func updateToDoItem(_ item: ToDoItem) {
        if let result = fetchToDoItemsFromCoreData(withPredicate: NSPredicate(format: "id == %@", item.id)),
           let objectToUpdate = result.first {
            objectToUpdate.title = item.title
            objectToUpdate.descriptions = item.descriptions
            objectToUpdate.due_date = item.due_date
            objectToUpdate.locations = item.locations
            objectToUpdate.priority = item.prority
            objectToUpdate.status = item.status
            objectToUpdate.time = item.time
            
            saveToCoreData()
            DispatchQueue.main.async {
                self.onUpdateToDoItemSuccess?()
            }
        } else {
            DispatchQueue.main.async {
                self.todoerrorHandler?()
            }
        }
    }
    
    // MARK: - Delete To-Do Item
    func deleteToDoItem(_ item: ToDoItem) {
        if let result = fetchToDoItemsFromCoreData(withPredicate: NSPredicate(format: "id == %@", item.id)),
           let objectToDelete = result.first {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let manageContext = appDelegate.persistentContainer.viewContext
            manageContext.delete(objectToDelete)
            saveToCoreData()
            DispatchQueue.main.async {
                self.onDeleteToDoItemSuccess?()
            }
        } else {
            DispatchQueue.main.async {
                self.todoerrorHandler?()
            }
        }
    }
}
