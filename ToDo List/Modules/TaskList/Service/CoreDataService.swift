//
//  CoreDataTaskService.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 18/9/25.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func saveTasks(_ tasks: [Task])
    func loadTasks() -> [Task]
    func addTask(_ task: Task)
    func updateTask(_ task: Task)
    func deleteTask(withId id: Int)
}

final class CoreDataService: CoreDataServiceProtocol {
    private let coreDataStack = CoreDataStack.shared
    
    func saveTasks(_ tasks: [Task]) {
        let context = coreDataStack.context
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: TaskEntity.fetchRequest())
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Error clear CoreData")
        }
        
        for task in tasks.reversed() {
            let newTask = TaskEntity(context: context)
            newTask.id = Int32(task.id)
            newTask.title = task.title
            newTask.taskDescription = task.description
            newTask.completed = task.completed
            newTask.userId = Int32(task.userId)
            newTask.date = task.date
            
            coreDataStack.saveContext()
        }
    }
    
    func loadTasks() -> [Task] {
        do {
            let tasks = try coreDataStack.context.fetch(TaskEntity.fetchRequest())
            return tasks.map { task in
                Task(
                    id: Int(task.id),
                    title: task.title,
                    description: task.taskDescription,
                    completed: task.completed,
                    userId: Int(task.userId),
                    date: task.date
                )
            }.reversed()
        } catch {
            return []
        }
    }
    
    func addTask(_ task: Task) {
        let newTask = TaskEntity(context: coreDataStack.context)
        newTask.id = Int32(task.id)
        newTask.title = task.title
        newTask.taskDescription = task.description
        newTask.completed = task.completed
        newTask.userId = Int32(task.userId)
        newTask.date = task.date
        
        coreDataStack.saveContext()
    }
    
    func updateTask(_ task: Task) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)
        
        do {
            let tasks = try coreDataStack.context.fetch(fetchRequest)
            if let newTask = tasks.first {
                newTask.title = task.title
                newTask.taskDescription = task.description
                newTask.completed = task.completed
                newTask.userId = Int32(task.userId)
                newTask.date = task.date
                coreDataStack.saveContext()
            }
        } catch {
            print("Error update CoreData")
        }
    }
    
    func deleteTask(withId id: Int) {
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", id)
        
        do {
            let tasks = try coreDataStack.context.fetch(fetchRequest)
            if let task = tasks.first {
                coreDataStack.context.delete(task)
                coreDataStack.saveContext()
            }
        } catch {
            print("Error delete CoreData")
        }
    }
}
