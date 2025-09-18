//
//  TaskDetailInteractorTests.swift
//  ToDoListTests
//
//  Created by Dmitriy Kalyakin on 18/9/25.
//

import XCTest
@testable import ToDo_List

private final class MockPresenter: TaskDetailInteractorOutputProtocol {
    private(set) var didSaveTasks: [Task] = []
    private(set) var didCloseCount: Int = 0
    
    func didSave(task: Task) {
        didSaveTasks.append(task)
    }
    
    func didClose() {
        didCloseCount += 1
    }
}

final class TaskDetailInteractorTests: XCTestCase {
    func testSaveTaskWithEmptyTitleCallDidClose() {
        let interactor = TaskDetailInteractor(task: nil)
        let presenter = MockPresenter()
        interactor.presenter = presenter
        
        interactor.saveTask(title: "", description: "test", date: Date())
        
        XCTAssertEqual(presenter.didCloseCount, 1)
        XCTAssertTrue(presenter.didSaveTasks.isEmpty)
    }
    
    func testSaveTaskWithNilTitleCallDidClose() {
        let interactor = TaskDetailInteractor(task: nil)
        let presenter = MockPresenter()
        interactor.presenter = presenter
        
        interactor.saveTask(title: nil, description: "test", date: Date())
        
        XCTAssertEqual(presenter.didCloseCount, 1)
        XCTAssertTrue(presenter.didSaveTasks.isEmpty)
    }
    
    func testSaveTaskCreateNewTaskWhenTaskNil() {
        let interactor = TaskDetailInteractor(task: nil)
        let presenter = MockPresenter()
        interactor.presenter = presenter
        let date = Date()
        interactor.saveTask(title: "Заголовок", description: "Описание", date: Date())
        
        XCTAssertEqual(presenter.didSaveTasks.count, 1)
        let saved = presenter.didSaveTasks.first
        XCTAssertEqual(saved?.title, "Заголовок")
        XCTAssertEqual(saved?.description, "Описание")
        XCTAssertEqual(saved?.completed, false)
        XCTAssertEqual(saved?.userId, 0)
        XCTAssertNotNil(saved?.id)
        guard let savedDate = saved?.date?.timeIntervalSince1970 else { XCTAssertNotNil(saved?.date?.timeIntervalSince1970); return }
        XCTAssertEqual(savedDate, date.timeIntervalSince1970, accuracy: 0.01)
    }
    
    func testSaveTaskUpdates() {
        let existing = Task(id: 1, title: "Old Title", description: "Old Description", completed: true, userId: 42, date: nil)
        let interactor = TaskDetailInteractor(task: existing)
        let presenter = MockPresenter()
        interactor.presenter = presenter
        let newTitle = "New Title"
        let newDescription = "New Description"
        let newDate = Date(timeIntervalSince1970: 1000)
        
        interactor.saveTask(title: newTitle, description: newDescription, date: newDate)
        
        XCTAssertEqual(presenter.didSaveTasks.count, 1)
        let saved = presenter.didSaveTasks.first
        XCTAssertEqual(saved?.id, existing.id)
        XCTAssertEqual(saved?.title, newTitle)
        XCTAssertEqual(saved?.description, newDescription)
        XCTAssertEqual(saved?.completed, existing.completed)
        XCTAssertEqual(saved?.userId, existing.userId)
        guard let savedDate = saved?.date?.timeIntervalSince1970 else { XCTAssertNotNil(saved?.date?.timeIntervalSince1970); return }
        XCTAssertEqual(savedDate, newDate.timeIntervalSince1970, accuracy: 0.01)
    }
}
