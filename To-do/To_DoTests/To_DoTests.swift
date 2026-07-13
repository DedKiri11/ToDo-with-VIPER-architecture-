//
//  To_doTests.swift
//  To_doTests
//
//  Created by Кирилл Зезюков on 10.07.2026.
//

import XCTest
@testable import To_do

final class To_DoTests: XCTestCase {

    private var interactor: ToDoInteractor!
    private var presenter: MockPresenter!
    private var coreData: MockCoreDataService!
    private var api: MockToDoAPIService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        coreData = MockCoreDataService(initial: [])
        api = MockToDoAPIService(stub: [])
        presenter = MockPresenter()
        
        interactor = ToDoInteractor(
            coreDataService: coreData,
            apiService: api
        )
        interactor.presenter = presenter
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        interactor = nil
        presenter = nil
        coreData = nil
        api = nil
    }
    
    // MARK: - findNextId
    
    func test_findNextId_emptyReturns1() throws {
        interactor.todos = []
        XCTAssertEqual(interactor.findNextId(), 1)
    }
    
    func test_findNextId_returnsMaxPlusOne() throws {
        interactor.todos = [
            ToDoEntity(id: 2, todo: "a", description: "", completed: false),
            ToDoEntity(id: 5, todo: "b", description: "", completed: true),
            ToDoEntity(id: 3, todo: "c", description: "", completed: false),
        ]
        XCTAssertEqual(interactor.findNextId(), 6)
    }
    
    func test_findNextId_handlesDuplicates() throws {
        interactor.todos = [
            ToDoEntity(id: 3, todo: "a", description: "", completed: false),
            ToDoEntity(id: 3, todo: "b", description: "", completed: false),
            ToDoEntity(id: 1, todo: "c", description: "", completed: false)
        ]
        XCTAssertEqual(interactor.findNextId(), 4)
    }
    
    // MARK: - retriveTodos
    
    func test_retriveTodos_callsPresenterOnMain() throws {
        let exp = expectation(description: "presentTodos called")
        let mockTodo = ToDoEntity(id: 1, todo: "a", description: "", completed: false)
        interactor.todos = [mockTodo]
        
        interactor.retriveTodos()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertEqual(self.presenter.presentTodosCalls.count, 1)
            XCTAssertEqual(self.presenter.presentTodosCalls, self.interactor.todos)
            XCTAssertEqual(self.presenter.presentTodosCalls.count, 1)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - loadTodos
    
    func test_loadTodos_usesDBIfHasData() throws {
        let existing = [
            ToDoEntity(id: 10, todo: "db1", description: "", completed: false),
            ToDoEntity(id: 11, todo: "db2", description: "", completed: true)
        ]
        coreData.setStorage(existing)
        
        let exp = expectation(description: "presentTodos called with DB")
        interactor.loadTodos()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            XCTAssertEqual(self.presenter.presentTodosCalls.count, 2)
            XCTAssertEqual(self.presenter.presentTodosCalls, existing)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadTodos_whenDBEmpty_downloadsFromAPI_andSavesToDB() throws {
        coreData.setStorage([])
        
        let apiTodos = [
            ToDoEntity(id: 1, todo: "api1", description: "", completed: false),
            ToDoEntity(id: 2, todo: "api2", description: "", completed: true)
        ]
        api = MockToDoAPIService(stub: apiTodos)
        
        interactor = ToDoInteractor(
            coreDataService: coreData,
            apiService: api
        )
        interactor.presenter = presenter
        
        let exp = expectation(description: "presentTodos called with API data")
        interactor.loadTodos()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertGreaterThanOrEqual(self.presenter.presentTodosCalls.count, 1)
            XCTAssertEqual(self.presenter.presentTodosCalls, apiTodos)
            XCTAssertEqual(self.coreData.getStorage(), apiTodos)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    // MARK: - createToDo
    
    func test_createToDo_assignsNextId_persists_andPresents() throws {
        interactor.todos = [
            ToDoEntity(id: 2, todo: "a", description: "", completed: false),
            ToDoEntity(id: 5, todo: "b", description: "", completed: true)
        ]
        coreData.setStorage(interactor.todos)
        
        let new = ToDoEntity(id: 0, todo: "new", description: "desc", completed: false)
        
        let exp = expectation(description: "presentTodos after create")
        interactor.createToDo(todo: new)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            XCTAssertGreaterThanOrEqual(self.presenter.presentTodosCalls.count, 2)
            XCTAssertTrue(self.presenter.presentTodosCalls.contains(where: { $0.todo == "new" && $0.id == 6 }))
            XCTAssertTrue(self.coreData.getStorage().contains(where: { $0.todo == "new" && $0.id == 6 }))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    // MARK: - updateToDo
    
    func test_updateToDo_persists_andPresents() throws {
        let initial = [
            ToDoEntity(id: 1, todo: "a", description: "", completed: false),
            ToDoEntity(id: 2, todo: "b", description: "", completed: false)
        ]
        interactor.todos = initial
        coreData.setStorage(initial)
        
        let updated = ToDoEntity(id: 2, todo: "b updated", description: "x", completed: true)
        
        let exp = expectation(description: "presentTodos after update")
        interactor.updateToDo(todo: updated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            XCTAssertGreaterThanOrEqual(self.presenter.presentTodosCalls.count, 1)
            XCTAssertTrue(self.presenter.presentTodosCalls.contains(where: { $0.id == 2 && $0.todo == "b updated" && $0.completed }))
            XCTAssertTrue(self.coreData.getStorage().contains(where: { $0.id == 2 && $0.todo == "b updated" && $0.completed }))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    // MARK: - deleteFromDb
    
    func test_deleteFromDb_removes_andPresents() throws {
        let initial = [
            ToDoEntity(id: 1, todo: "a", description: "", completed: false),
            ToDoEntity(id: 2, todo: "b", description: "", completed: false)
        ]
        interactor.todos = initial
        coreData.setStorage(initial)
        
        let exp = expectation(description: "presentTodos after delete")
        interactor.deleteFromDb(todo: ToDoEntity(id: 2, todo: "", description: "", completed: false))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            XCTAssertGreaterThanOrEqual(self.presenter.presentTodosCalls.count, 1)
            XCTAssertFalse(self.presenter.presentTodosCalls.contains(where: { $0.id == 2 }))
            XCTAssertFalse(self.coreData.getStorage().contains(where: { $0.id == 2 }))
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2.0)
    }
    
    // MARK: - API test

    func test_api_calls_to_presenter() throws {
        let exp = expectation(description: "no data")
        ToDoAPIService.shared.getData { result in
            XCTAssertNotNil(result)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
    }
}
