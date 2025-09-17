//
//  TaskListPresenter.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import UIKit

protocol TaskListPresenterProtocol: AnyObject {
    
    var view: TaskListViewProtocol? { get set }
    var interactor: TaskListInteractorInputProtocol { get set }
    var router: TaskListRouterProtocol? { get set }
    
    func loadTasks()
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func didLoadTasks(_ tasks: [Task])
    func didFailLoadingTasks(_ error: Error)
}

final class TaskListPresenter: TaskListPresenterProtocol {
    
    weak var view: TaskListViewProtocol?
    var interactor: TaskListInteractorInputProtocol
    var router: TaskListRouterProtocol?
    
    init(interactor: TaskListInteractorInputProtocol) {
        self.interactor = interactor
    }
    
    func loadTasks() {
        interactor.loadTasks()
    }
}

extension TaskListPresenter: TaskListInteractorOutputProtocol {
    func didLoadTasks(_ tasks: [Task]) {
        DispatchQueue.main.async {
            self.view?.show(tasks)
        }
    }
    
    func didFailLoadingTasks(_ error: any Error) {
        DispatchQueue.main.async {
            self.view?.showLoadError(error.localizedDescription)
        }
    }
}
