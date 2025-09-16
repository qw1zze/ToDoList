//
//  TaskListInteractor.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

protocol TaskListInteractorInputProtocol: AnyObject {
    
    var presenter: TaskListInteractorOutputProtocol { get set }
}

final class TaskListInteractor: TaskListInteractorInputProtocol {
   
    var presenter: TaskListInteractorOutputProtocol
    
    init(presenter: TaskListInteractorOutputProtocol) {
        self.presenter = presenter
    }
}
