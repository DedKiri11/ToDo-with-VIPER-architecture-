//
//  File.swift
//  To_doTests
//
//  Created by Кирилл Зезюков on 13.07.2026.
//

import Foundation
@testable import To_do

final class MockCoreDataService: CoreDataServiceProtocol {
    private var storage: [ToDoEntity] = []
    
    init(initial: [ToDoEntity] = []) {
        self.storage = initial
    }
    
    func fetchTodos(completion: @escaping ([ToDoEntity]) -> Void) {
        DispatchQueue.main.async {
            completion(self.storage)
        }
    }
    
    func downloadTodos(todos: [ToDoEntity]) {
        storage.append(contentsOf: todos)
    }
    
    func createToDo(todo: ToDoEntity, completion: @escaping () -> Void) {
        storage.append(todo)
        DispatchQueue.main.async { completion() }
    }
    
    func updateToDo(todo: ToDoEntity, completion: @escaping () -> Void) {
        if let idx = storage.firstIndex(where: { $0.id == todo.id }) {
            storage[idx] = todo
        }
        DispatchQueue.main.async { completion() }
    }
    
    func deleteToDo(todo: ToDoEntity, completion: @escaping () -> Void) {
        storage.removeAll { $0.id == todo.id }
        DispatchQueue.main.async { completion() }
    }
    
    func setStorage(_ todos: [ToDoEntity]) {
        storage = todos
    }
    
    func getStorage() -> [ToDoEntity] {
        return storage
    }
}
