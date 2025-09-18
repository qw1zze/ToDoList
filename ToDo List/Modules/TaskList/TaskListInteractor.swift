//
//  TaskListInteractor.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import Foundation

protocol TaskListInteractorInputProtocol: AnyObject {
    var presenter: TaskListInteractorOutputProtocol? { get set }
    
    func loadTasks()
    func filterTasks(_ text: String?)
    func makeDone(task: Task, completed: Bool)
    func deleteTask(_ task: Task)
    func addTask(_ task: Task)
    func updateTask(_ task: Task)
}

final class TaskListInteractor: TaskListInteractorInputProtocol {
   
    weak var presenter: TaskListInteractorOutputProtocol?
    private let downloadService: TaskDownloadServicing
    private let coreDataService: CoreDataServiceProtocol
    
    private var tasks : [Task] = []
    private var shownTasks: [Task] = []
    
    init(downloadService: TaskDownloadServicing = TaskDownloadService(), 
         coreDataService: CoreDataServiceProtocol = CoreDataService()) {
        self.downloadService = downloadService
        self.coreDataService = coreDataService
    }
    
    func loadTasks() {
        if AppLaunchManager.shared.isFirstLaunch {
            refreshTasks()
        } else {
            let savedTasks = coreDataService.loadTasks()
            self.tasks = savedTasks
            self.shownTasks = savedTasks
            self.presenter?.updateTasks(savedTasks)
        }
    }
    
    func filterTasks(_ text: String?) {
        let text = text?.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if text.isEmpty {
            shownTasks = tasks
        } else {
            shownTasks = tasks.filter { task in
                let title = task.title?.lowercased() ?? ""
                let description = task.description?.lowercased() ?? ""
                return title.contains(text) || description.contains(text)
            }
        }
        
        presenter?.updateTasks(shownTasks)
    }
    
    func makeDone(task: Task, completed: Bool) {
        if let id = self.tasks.firstIndex(where: { $0.id == task.id }) {
            self.tasks[id].completed = completed
        }
        
        if let id = self.shownTasks.firstIndex(where: { $0.id == task.id }) {
            self.shownTasks[id].completed = completed
            presenter?.updateTasks(shownTasks)
        }
        
        var newTask = task
        newTask.completed = completed
        coreDataService.updateTask(newTask)
    }
    
    func deleteTask(_ task: Task) {
        if let id = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks.remove(at: id)
        }
        
        if let id = shownTasks.firstIndex(where: { $0.id == task.id }) {
            shownTasks.remove(at: id)
            presenter?.updateTask(id, tasks: shownTasks)
        }
        
        coreDataService.deleteTask(withId: task.id)
    }
    
    func addTask(_ task: Task) {
        tasks.insert(task, at: 0)
        shownTasks.insert(task, at: 0)
        presenter?.updateTasks(shownTasks)
        
        coreDataService.addTask(task)
    }
    
    func updateTask(_ task: Task) {
        if let id = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[id] = task
        }
        
        if let id = shownTasks.firstIndex(where: { $0.id == task.id }) {
            shownTasks[id] = task
            presenter?.updateTasks(shownTasks)
        }
        
        coreDataService.updateTask(task)
    }
    
    private func addDatesToTasks(tasks: [Task]) -> [Task] {
        return tasks.compactMap {
            Task(
                id: $0.id,
                title: $0.title,
                description: $0.description,
                completed: $0.completed,
                userId: $0.userId,
                date: $0.date == nil ? Date() : $0.date
            )
        }
    }
    
    private func refreshTasks() {
        downloadService.fetchData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let list):
                let formattedTasks = addDatesToTasks(tasks: list.tasks)
                self.tasks = formattedTasks
                self.shownTasks = formattedTasks
                self.coreDataService.saveTasks(formattedTasks)
                self.presenter?.updateTasks(formattedTasks)
                AppLaunchManager.shared.markAsLaunched()
            case .failure(let error):
                self.presenter?.didFailLoadingTasks(error)
            }
        }
    }
}
