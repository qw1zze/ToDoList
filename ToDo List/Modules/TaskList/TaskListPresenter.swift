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
    func searchTextDidChange(_ text: String?)
    func updateTaskState(task: Task, done completed: Bool)
    func didSelectShare(vc: UIViewController, _ task: Task)
    func didSelectDelete(_ task: Task)
    func didSelectCreate(from vc: UIViewController)
    func didSelectEdit(from vc: UIViewController, task: Task)
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    func updateTasks(_ tasks: [Task])
    func didFailLoadingTasks(_ error: Error)
    func updateTask(_ row: Int, tasks: [Task])
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
    
    func searchTextDidChange(_ text: String?) {
        interactor.filterTasks(text)
    }
    
    func updateTaskState(task: Task, done completed: Bool) {
        interactor.makeDone(task: task, completed: completed)
    }
    
    func didSelectShare(vc: UIViewController, _ task: Task) {
        router?.routeToShare(from: vc, task)
    }
    
    func didSelectDelete(_ task: Task) {
        interactor.deleteTask(task)
    }

    func didSelectCreate(from view: UIViewController) {
        router?.routeToCreate(from: view) { [weak self] task in
            self?.interactor.addTask(task)
        }
    }
    
    func didSelectEdit(from vc: UIViewController, task: Task) {
        router?.routeToEdit(from: vc, task: task) { [weak self] task in
            self?.interactor.updateTask(task)
        }
    }
}

extension TaskListPresenter: TaskListInteractorOutputProtocol {
    func updateTasks(_ tasks: [Task]) {
        DispatchQueue.main.async {
            self.view?.show(tasks)
        }
    }
    
    func didFailLoadingTasks(_ error: any Error) {
        DispatchQueue.main.async {
            self.view?.showLoadError(error.localizedDescription)
        }
    }
    
    func updateTask(_ row: Int, tasks: [Task]) {
        DispatchQueue.main.async {
            self.view?.applyTableChanges(model: .delete(IndexPath(row: row, section: 0), tasks: tasks))
        }
    }
}
