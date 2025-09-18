//
//  CoreDataServiceTests.swift
//  ToDoListTests
//
//  Created by Dmitriy Kalyakin on 18/9/25.
//

import XCTest
import CoreData
@testable import ToDo_List

final class CoreDataStackMock: CoreDataStacking {
    private let container: NSPersistentContainer
    private let background: NSManagedObjectContext
    
    init() {
        let modelURL = Bundle(for: CoreDataServiceTests.self).url(forResource: "ToDoList", withExtension: "momd") ?? Bundle.main.url(forResource: "ToDoList", withExtension: "momd")!
        container = NSPersistentContainer(name: "ToDoList", managedObjectModel: NSManagedObjectModel(contentsOf: modelURL)!)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
        background = container.newBackgroundContext()
        background.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func getBackgroundContext() -> NSManagedObjectContext { background }
    func saveBackgroundContext() {}
}

final class CoreDataServiceTests: XCTestCase {
    private var stack: CoreDataStackMock! = nil
    private var service: CoreDataService! = nil
    
    override func setUp() {
        super.setUp()
        stack = CoreDataStackMock()
        service = CoreDataService(coreDataStack: stack)
    }
    
    override func tearDown() {
        stack = nil
        service = nil
        super.tearDown()
    }
    
    private func makeTask(id: Int = 1, title: String = "title", desc: String? = nil, completed: Bool = false, userId: Int = 1, date: Date = Date()) -> Task {
        Task(id: id, title: title, description: desc, completed: completed, userId: userId, date: date)
    }
    
    func testAddUpdateDelete() {
        let addExpectation = expectation(description: "add")
        let task = makeTask(id: 10, title: "title")
        service.addTask(task) { result in
            if case .failure(_) = result { XCTFail("Error") }
            addExpectation.fulfill()
        }
        wait(for: [addExpectation], timeout: 1)
        
        let updateExpectation = expectation(description: "update")
        let updatedTask = makeTask(id: 10, title: "new Title")
        service.updateTask(updatedTask) { result in
            if case .failure(_) = result { XCTFail("Error") }
            updateExpectation.fulfill()
        }
        wait(for: [updateExpectation], timeout: 1)
        
        let verifyExpectation = expectation(description: "verify")
        service.loadTasks { result in
            let loadedTask = try? result.get()
            XCTAssertEqual(loadedTask?.first?.title, "new Title")
            verifyExpectation.fulfill()
        }
        wait(for: [verifyExpectation], timeout: 1)
        
        let deleteExpectation = expectation(description: "delete")
        service.deleteTask(withId: 10) { result in
            if case .failure(_) = result { XCTFail("Error") }
            deleteExpectation.fulfill()
        }
        wait(for: [deleteExpectation], timeout: 1)
        
        let loadExpecation = expectation(description: "load2")
        service.loadTasks { result in
            let loadedTask = try? result.get()
            XCTAssertEqual(loadedTask?.contains(where: { $0.id == 10 }), false)
            loadExpecation.fulfill()
        }
        wait(for: [loadExpecation], timeout: 1)
    }
}
