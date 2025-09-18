//
//  CoreDataTaskService.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 18/9/25.
//

import Foundation
import CoreData

protocol CoreDataServiceProtocol {
    func saveTasks(_ tasks: [Task], completion: @escaping (Result<Void, Error>) -> Void)
    func loadTasks(completion: @escaping (Result<[Task], Error>) -> Void)
    func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func updateTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void)
    func deleteTask(withId id: Int, completion: @escaping (Result<Void, Error>) -> Void)
}

final class CoreDataService: CoreDataServiceProtocol {
    private let coreDataStack = CoreDataStack.shared
    
    func saveTasks(_ tasks: [Task], completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Error CoreData", code: -1)))
                }
                return
            }
            
            let backgroundContext = self.coreDataStack.getBackgroundContext()
            
            backgroundContext.perform {
                do {
                    try backgroundContext.execute(NSBatchDeleteRequest(fetchRequest: TaskEntity.fetchRequest()))
                    
                    for task in tasks.reversed() {
                        let newTask = TaskEntity(context: backgroundContext)
                        newTask.id = Int32(task.id)
                        newTask.title = task.title
                        newTask.taskDescription = task.description
                        newTask.completed = task.completed
                        newTask.userId = Int32(task.userId)
                        newTask.date = task.date
                        
                        self.coreDataStack.saveBackgroundContext()
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func loadTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Error CoreData", code: -1)))
                }
                return
            }
            
            let backgroundContext = self.coreDataStack.getBackgroundContext()
            
            backgroundContext.perform {
                do {
                    let tasks = try backgroundContext.fetch(TaskEntity.fetchRequest())
                    let result = tasks.map { task in
                        Task(
                            id: Int(task.id),
                            title: task.title,
                            description: task.taskDescription,
                            completed: task.completed,
                            userId: Int(task.userId),
                            date: task.date
                        )
                    }.reversed()
                    
                    DispatchQueue.main.async {
                        completion(.success(Array(result)))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Error CoreData", code: -1)))
                }
                return
            }
            
            let backgroundContext = self.coreDataStack.getBackgroundContext()
            
            backgroundContext.perform {
                let newTask = TaskEntity(context: backgroundContext)
                newTask.id = Int32(task.id)
                newTask.title = task.title
                newTask.taskDescription = task.description
                newTask.completed = task.completed
                newTask.userId = Int32(task.userId)
                newTask.date = task.date
                
                self.coreDataStack.saveBackgroundContext()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            }
        }
    }
    
    func updateTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Error CoreData", code: -1)))
                }
                return
            }
            
            let backgroundContext = self.coreDataStack.getBackgroundContext()
            
            backgroundContext.perform {
                do {
                    let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %d", task.id)
                    
                    let tasks = try backgroundContext.fetch(fetchRequest)
                    if let newTask = tasks.first {
                        newTask.title = task.title
                        newTask.taskDescription = task.description
                        newTask.completed = task.completed
                        newTask.userId = Int32(task.userId)
                        newTask.date = task.date
                        
                        self.coreDataStack.saveBackgroundContext()
                        
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "Error CoreData", code: -1)))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func deleteTask(withId id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Error CoreData", code: -1)))
                }
                return
            }
            
            let backgroundContext = self.coreDataStack.getBackgroundContext()
            
            backgroundContext.perform {
                do {
                    let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                    fetchRequest.predicate = NSPredicate(format: "id == %d", id)
                    
                    let tasks = try backgroundContext.fetch(fetchRequest)
                    if let task = tasks.first {
                        backgroundContext.delete(task)
                        self.coreDataStack.saveBackgroundContext()
                        
                        DispatchQueue.main.async {
                            completion(.success(()))
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "Error CoreData", code: -1)))
                        }
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
