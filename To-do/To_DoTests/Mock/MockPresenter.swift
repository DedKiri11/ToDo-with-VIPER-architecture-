//
//  MockPresenter.swift
//  To_do
//
//  Created by Кирилл Зезюков Тимонова on 13.07.2026.
//

import Foundation
@testable import To_do

final class MockPresenter: ToDoPresenterProtocol {
    private(set) var presentTodosCalls: [ToDoEntity] = []
    private(set) var deleteToDoCalled = false
    private(set) var updateToDoCalled = false
    private(set) var addToDoCalled = false
    private(set) var viewWillAppearCalled = false
    
    func deleteToDo(todo: ToDoEntity) {
        deleteToDoCalled = true
    }
    
    func updateToDo(todo: ToDoEntity) {
        updateToDoCalled = true
    }
    
    func addToDo(todo: ToDoEntity) {
        addToDoCalled = true
    }
    
    func viewWillAppear() {
        viewWillAppearCalled = true
    }
    
    func presentTodos(todos: [ToDoEntity]) {
        presentTodosCalls.append(contentsOf: todos)
    }
}
