//
//  TaskListInteractorTests.swift
//  ToDoListTests
//
//  Created by Dmitriy Kalyakin on 18/9/25.
//

import XCTest
@testable import ToDo_List

private final class PresenterMock: TaskListInteractorOutputProtocol {
    private(set) var updatedTasksHistory: [[Task]] = []
    private(set) var lastError: Error?
    private(set) var updateTaskCalls: [(row: Int, tasks: [Task])] = []
    
    func reset() {
        updatedTasksHistory.removeAll()
        lastError = nil
        updateTaskCalls.removeAll()
    }

    func updateTasks(_ tasks: [Task]) {
        updatedTasksHistory.append(tasks)
    }
    
    func didFailLoadingTasks(_ error: Error) {
        lastError = error
    }
    
    func updateTask(_ row: Int, tasks: [Task]) {
        updateTaskCalls.append((row, tasks))
    }
}

private struct MockError: Error {}

private final class DownloadServiceMock: TaskDownloadServicing {
    var result: Result<TaskList, Error> = .success(TaskList(tasks: [], total: 0, skip: 0, limit: 0))
    
    func fetchData(completion: @escaping (Result<TaskList, Error>) -> Void) {
        completion(result)
    }
}

private final class CoreDataServiceMock: CoreDataServiceProtocol {
    var savedTasks: [Task] = []
    var loadResult: Result<[Task], Error> = .success([])
    var addResult: Result<Void, Error> = .success(())
    var updateResult: Result<Void, Error> = .success(())
    var deleteResult: Result<Void, Error> = .success(())
    
    func saveTasks(_ tasks: [Task], completion: @escaping (Result<Void, Error>) -> Void) {
        savedTasks = tasks
        completion(.success(()))
    }
    
    func loadTasks(completion: @escaping (Result<[Task], Error>) -> Void) {
        completion(loadResult)
    }
    
    func addTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        addResult.fold(onSuccess: { completion(.success(())) }, onFailure: { completion(.failure($0)) })
    }
    
    func updateTask(_ task: Task, completion: @escaping (Result<Void, Error>) -> Void) {
        updateResult.fold(onSuccess: { completion(.success(())) }, onFailure: { completion(.failure($0)) })
    }
    
    func deleteTask(withId id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        deleteResult.fold(onSuccess: { completion(.success(())) }, onFailure: { completion(.failure($0)) })
    }
}

private extension Result {
    func fold(onSuccess: (Success) -> Void, onFailure: (Failure) -> Void) {
        switch self {
        case .success(let value): onSuccess(value)
        case .failure(let error): onFailure(error)
        }
    }
}

final class TaskListInteractorTests: XCTestCase {
    override func setUp() {
        super.setUp()
        AppLaunchManager.shared.isFirstLaunch = true
    }
    
    func makeTask(id: Int = 1, title: String = "Title", description: String = "Description", completed: Bool = false, userId: Int = 0, date: Date? = nil) -> Task {
        Task(id: id, title: title, description: description, completed: completed, userId: userId, date: date)
    }
    
    func testLoadTasksFirstLaunchDownloadsSaves() {
        let list = TaskList(tasks: [makeTask(id: 1, date: nil), makeTask(id: 2, date: nil)], total: 2, skip: 0, limit: 2)
        let download = DownloadServiceMock()
        download.result = .success(list)
        let core = CoreDataServiceMock()
        let interactor = TaskListInteractor(downloadService: download, coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter
        
        interactor.loadTasks()
        
        XCTAssertEqual(core.savedTasks.count, 2)
        XCTAssertEqual(presenter.updatedTasksHistory.last?.count, 2)
        XCTAssertTrue(core.savedTasks.allSatisfy { $0.date != nil })
        XCTAssertTrue(presenter.updatedTasksHistory.last?.allSatisfy { $0.date != nil } ?? false)
        XCTAssertFalse(AppLaunchManager.shared.isFirstLaunch)
    }
    
    func testLoadTasksFirstLaunchDownloadFails() {
        let download = DownloadServiceMock()
        download.result = .failure(MockError())
        let interactor = TaskListInteractor(downloadService: download, coreDataService: CoreDataServiceMock())
        let presenter = PresenterMock()
        interactor.presenter = presenter
        
        interactor.loadTasks()
        
        XCTAssertNotNil(presenter.lastError)
        XCTAssertTrue(presenter.updatedTasksHistory.isEmpty)
    }
    
    func testLoadTasksNotFirstLaunchLoadCoreData() {
        AppLaunchManager.shared.isFirstLaunch = false
        let saved = [makeTask(id: 1), makeTask(id: 2)]
        let core = CoreDataServiceMock()
        core.loadResult = .success(saved)
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter
        
        interactor.loadTasks()
        
        let last = presenter.updatedTasksHistory.last ?? []
        XCTAssertEqual(last.count, saved.count)
        XCTAssertEqual(last.map { $0.id }, saved.map { $0.id })
        XCTAssertNil(presenter.lastError)
    }
    
    func testFilterTasks() {
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: CoreDataServiceMock())
        let presenter = PresenterMock()
        interactor.presenter = presenter
        
        interactor.addTask(makeTask(id: 1, title: "1", description: "11"))
        interactor.addTask(makeTask(id: 2, title: "2", description: "22"))
        interactor.addTask(makeTask(id: 3, title: "3", description: "332"))
        
        let exp = expectation(description: "filter async")
        DispatchQueue.global().async {
            interactor.filterTasks("2")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { exp.fulfill() }
        }
        wait(for: [exp], timeout: 1)
        
        XCTAssertEqual(presenter.updatedTasksHistory.last?.map { $0.id }, [3, 2])
    }
    
    func testMakeDone() {
        let core = CoreDataServiceMock()
        core.updateResult = .failure(MockError())
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter
        let task = makeTask(id: 1, completed: false)
        interactor.addTask(task)
        presenter.reset()
        
        interactor.makeDone(task: task, completed: true)

        XCTAssertNotNil(presenter.lastError)
        XCTAssertEqual(presenter.updatedTasksHistory.last?.first?.completed, false)
    }
    
    func testDeleteTaskSuccess() {
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: CoreDataServiceMock())
        let presenter = PresenterMock()
        interactor.presenter = presenter
        let task1 = makeTask(id: 1)
        let task2 = makeTask(id: 2)
        interactor.addTask(task2)
        interactor.addTask(task1)
        presenter.reset()
        
        interactor.deleteTask(task1)
        
        XCTAssertEqual(presenter.updateTaskCalls.last?.row, 0)
        XCTAssertEqual(presenter.updateTaskCalls.last?.tasks.map { $0.id }, [2])
    }
    
    func testDeleteTaskFailed() {
        let core = CoreDataServiceMock()
        core.deleteResult = .failure(MockError())
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter
        let task1 = makeTask(id: 1)
        let task2 = makeTask(id: 2)
        interactor.addTask(task2)
        interactor.addTask(task1)
        presenter.reset()
        
        interactor.deleteTask(task1)
        
        XCTAssertNotNil(presenter.lastError)
        XCTAssertEqual(presenter.updatedTasksHistory.last?.map { $0.id }, [2])
    }
    
    func testAddTask() {
        let core = CoreDataServiceMock()
        core.addResult = .failure(MockError())
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter
        let task = makeTask(id: 10)
        presenter.reset()
        
        interactor.addTask(task)
        
        XCTAssertNotNil(presenter.lastError)
        XCTAssertEqual(presenter.updatedTasksHistory.last?.isEmpty, true)
    }
    
    func testUpdateTask() {
        let core = CoreDataServiceMock()
        core.updateResult = .failure(MockError())
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter
        let original = makeTask(id: 5, title: "Old")
        let updated = makeTask(id: 5, title: "New")
        interactor.addTask(original)
        presenter.reset()
        
        interactor.updateTask(updated)
        
        XCTAssertNotNil(presenter.lastError)
        XCTAssertEqual(presenter.updatedTasksHistory.last?.first?.title, "Old")
    }

    func testLoadTasksCoreData() {
        let core = CoreDataServiceMock()
        core.loadResult = .success([makeTask(id: 1), makeTask(id: 2)])
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter

        AppLaunchManager.shared.isFirstLaunch = false
        interactor.loadTasks()

        XCTAssertEqual(presenter.updatedTasksHistory.last?.count, 2)
    }

    func testMakeDoneUpdates() {
        let core = CoreDataServiceMock()
        core.loadResult = .success([makeTask(id: 1, completed: false)])
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter
        AppLaunchManager.shared.isFirstLaunch = false
        
        interactor.loadTasks()

        let task = makeTask(id: 1, completed: false)
        interactor.makeDone(task: task, completed: true)

        XCTAssertEqual(presenter.updatedTasksHistory.last?.first?.completed, true)
    }

    func testAddUpdateDelete() {
        let core = CoreDataServiceMock()
        core.loadResult = .success([])
        let interactor = TaskListInteractor(downloadService: DownloadServiceMock(), coreDataService: core)
        let presenter = PresenterMock()
        interactor.presenter = presenter
        AppLaunchManager.shared.isFirstLaunch = false
        
        interactor.loadTasks()
        interactor.addTask(makeTask(id: 10))
        
        XCTAssertEqual(presenter.updatedTasksHistory.last?.first?.id, 10)

        let updated = Task(id: 10, title: "New", description: nil, completed: false, userId: 1, date: Date())
        interactor.updateTask(updated)
        interactor.deleteTask(updated)
        
        XCTAssertEqual(presenter.updateTaskCalls.last?.0, 0)
    }
}
