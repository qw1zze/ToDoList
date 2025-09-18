//
//  TaskListBuilder.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import UIKit

enum TaskListAssembly {
    static func build(service: TaskDownloadServicing = TaskDownloadService()) -> UIViewController {
        let interactor = TaskListInteractor(downloadService: service)
        let presenter = TaskListPresenter(interactor: interactor)
        let router = TaskListRouter()
        let viewController = TaskListViewController(presenter: presenter)
        
        presenter.view = viewController
        presenter.router = router
        interactor.presenter = presenter
        
        return viewController
    }
}
