//
//  CoreDataStack.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 18/9/25.
//

import CoreData
import Foundation

protocol CoreDataStacking {
    func getBackgroundContext() -> NSManagedObjectContext
    func saveBackgroundContext()
}

class CoreDataStack: CoreDataStacking {
    static let shared = CoreDataStack()
    
    private init() {}
    
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ToDoList")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Error with Container")
            }
        }
        return container
    }()
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    func getBackgroundContext() -> NSManagedObjectContext {
        return backgroundContext
    }
    
    func saveBackgroundContext() {
        if backgroundContext.hasChanges {
            do {
                try backgroundContext.save()
            } catch {
                fatalError("Error with Context")
            }
        }
    }
}
