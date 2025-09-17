//
//  TaskListInteractor.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

protocol TaskListInteractorInputProtocol: AnyObject {
    
    var presenter: TaskListInteractorOutputProtocol? { get set }
    
    func loadTasks()
}

final class TaskListInteractor: TaskListInteractorInputProtocol {
   
    weak var presenter: TaskListInteractorOutputProtocol?
    private let downloadService: TaskDownloadService
    
    init(downloadService: TaskDownloadService = .init()) {
        self.downloadService = downloadService
    }
    
    func loadTasks() {
        downloadService.fetchData { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let list):
                self.presenter?.didLoadTasks(list.tasks)
            case .failure(let error):
                self.presenter?.didFailLoadingTasks(error)
            }
        }
    }
}
