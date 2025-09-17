//
//  TaskDetailAssembly.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import UIKit

enum TaskDetailAssembly {
    static func build(task: Task? = nil, completion: ((Task) -> Void)? = nil) -> UIViewController {
        let interactor = TaskDetailInteractor(task: task)
        let presenter = TaskDetailPresenter(interactor: interactor, completion: completion)
        let router = TaskDetailRouter()
        let viewController = TaskDetailViewController(presenter: presenter)
        
        presenter.view = viewController
        presenter.router = router
        interactor.presenter = presenter
        
        return viewController
    }
}


