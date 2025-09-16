//
//  TaskListViewController.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import UIKit

protocol TaskListViewProtocol: AnyObject {
    
    var presenter: TaskListPresenterProtocol? { get set }
    
}

final class TaskListViewController: UIViewController {
    
    weak var presenter: TaskListPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TaskListViewController: TaskListViewProtocol {
    
}
