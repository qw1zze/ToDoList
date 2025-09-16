//
//  TaskListPresenter.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import UIKit

protocol TaskListPresenterProtocol: AnyObject {
    
    var view: TaskListViewProtocol { get set }
    var interactor: TaskListInteractorInputProtocol? { get set }
    var router: TaskListRouterProtocol? { get set }
    
}

protocol TaskListInteractorOutputProtocol: AnyObject {
    
}

final class TaskListPresenter: TaskListPresenterProtocol {
    
    var view: TaskListViewProtocol
    weak var interactor: TaskListInteractorInputProtocol?
    var router: TaskListRouterProtocol?
    
    init(view: TaskListViewProtocol) {
        self.view = view
    }
    
}

extension TaskListPresenter: TaskListInteractorOutputProtocol {
    
}
