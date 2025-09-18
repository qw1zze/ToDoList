//
//  TaskListConfigurator.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import UIKit

protocol TaskListRouterProtocol: AnyObject {
    func routeToShare(from view: UIViewController, _ task: Task)
    func routeToCreate(from view: UIViewController, completion: @escaping (Task) -> Void)
    func routeToEdit(from view: UIViewController, task: Task, completion: @escaping (Task) -> Void)
}

final class TaskListRouter: TaskListRouterProtocol {
    func routeToShare(from view: UIViewController, _ task: Task) {
        let text = [task.title, task.description].compactMap { $0 }.joined(separator: "\n")
        let vc = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        vc.popoverPresentationController?.sourceView = view.view
        view.present(vc, animated: true)
    }

    func routeToCreate(from view: UIViewController, completion: @escaping (Task) -> Void) {
        let vc = TaskDetailAssembly.build(task: nil, completion: completion)
        view.navigationController?.pushViewController(vc, animated: true)
    }
    
    func routeToEdit(from view: UIViewController, task: Task, completion: @escaping (Task) -> Void) {
        let vc = TaskDetailAssembly.build(task: task, completion: completion)
        view.navigationController?.pushViewController(vc, animated: true)
    }
}
