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
        let viewController = TaskListViewController()
        let presenter = TaskListPresenter(view: viewController)
        let interactor = TaskListInteractor(presenter: presenter)
        
        viewController.presenter = presenter
        presenter.interactor = interactor
        presenter.router = TaskListRouter()
        return viewController
    }
    
}
