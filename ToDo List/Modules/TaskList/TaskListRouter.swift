//
//  TaskListConfigurator.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import UIKit

protocol TaskListRouterProtocol: AnyObject {
    static func build() -> UIViewController
}

final class TaskListRouter: TaskListRouterProtocol {
    
    static func build() -> UIViewController {
        let interactor = TaskListInteractor()
        let presenter = TaskListPresenter(interactor: interactor)
        let viewController = TaskListViewController(presenter: presenter)
        
        presenter.view = viewController
        interactor.presenter = presenter
        presenter.router = TaskListRouter()
        return viewController
    }
    
}
