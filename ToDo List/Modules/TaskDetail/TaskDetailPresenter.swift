//
//  TaskDetailPresenter.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import UIKit

protocol TaskDetailPresenterProtocol: AnyObject {
    
    var view: TaskDetailViewProtocol? { get set }
    var interactor: TaskDetailInteractorInputProtocol { get set }
    var router: TaskDetailRouterProtocol? { get set }
    var completion: ((Task) -> Void)? { get set }
    
    func viewDidLoad()
    func didTapSave(title: String?, description: String?, date: Date?)
}

protocol TaskDetailInteractorOutputProtocol: AnyObject {
    func didSave(task: Task)
    func didClose()
}

final class TaskDetailPresenter: TaskDetailPresenterProtocol {
    weak var view: TaskDetailViewProtocol?
    var interactor: TaskDetailInteractorInputProtocol
    var router: TaskDetailRouterProtocol?
    var completion: ((Task) -> Void)?
    
    init(interactor: TaskDetailInteractorInputProtocol, completion: ((Task) -> Void)? = nil) {
        self.interactor = interactor
        self.completion = completion
    }
    
    func viewDidLoad() {
        guard let task = interactor.initialTask else { return }
        view?.fill(with: task)
    }
    
    func didTapSave(title: String?, description: String?, date: Date?) {
        interactor.saveTask(title: title, description: description, date: date)
    }
}

extension TaskDetailPresenter: TaskDetailInteractorOutputProtocol {
    func didSave(task: Task) {
        DispatchQueue.main.async {
            self.completion?(task)
            self.router?.close(view: self.view)
        }
    }
    
    func didClose() {
        DispatchQueue.main.async {
            self.router?.close(view: self.view)
        }
    }
}
