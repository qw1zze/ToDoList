//
//  TaskDetailRouter.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import UIKit

protocol TaskDetailRouterProtocol: AnyObject {
    func close(view: UIViewController?)
}

final class TaskDetailRouter: TaskDetailRouterProtocol {
    func close(view: UIViewController?) {
        if let nav = view?.navigationController {
            nav.popViewController(animated: true)
        } else {
            view?.dismiss(animated: true)
        }
    }
}
