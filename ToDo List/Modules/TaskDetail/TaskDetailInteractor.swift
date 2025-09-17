//
//  TaskDetailInteractor.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import Foundation

protocol TaskDetailInteractorInputProtocol: AnyObject {
    var presenter: TaskDetailInteractorOutputProtocol? { get set }
    var initialTask: Task? { get }
    
    func saveTask(title: String?, description: String?, date: Date?)
}

final class TaskDetailInteractor: TaskDetailInteractorInputProtocol {
    
    weak var presenter: TaskDetailInteractorOutputProtocol?
    private var task: Task?
    
    var initialTask: Task? {
        return task
    }
    
    init(task: Task?) {
        self.task = task
    }
    
    func saveTask(title: String?, description: String?, date: Date?) {
        guard let title, !title.isEmpty else { presenter?.didClose(); return }
        
        if let task {
            let newTask = Task(
                id: task.id,
                title: title,
                description: description,
                completed: task.completed,
                userId: task.userId,
                date: date
            )
            presenter?.didSave(task: newTask)
        } else {
            let newTask = Task(
                id: Int(Date().timeIntervalSince1970),
                title: title,
                description: description,
                completed: false,
                userId: 0,
                date: date
            )
            presenter?.didSave(task: newTask)
        }
    }
}
