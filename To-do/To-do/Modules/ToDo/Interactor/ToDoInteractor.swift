//
//  ToDoInteractor.swift
//  To-do
//
//  Created by Кирилл Зезюков on 28.08.2024.
//

import UIKit

final class ToDoInteractor: ToDoInteractorProtocol {
    weak var presenter: ToDoPresenterProtocol?
    var todos: [ToDoEntity] = []
    
      private let coreDataService: CoreDataServiceProtocol
      private let apiService: ToDoAPIServiceProtocol
      
      convenience init() {
          self.init(
              coreDataService: CoreDataService.shared,
              apiService: ToDoAPIService.shared
          )
      }
      
      init(coreDataService: CoreDataServiceProtocol, apiService: ToDoAPIServiceProtocol) {
          self.coreDataService = coreDataService
          self.apiService = apiService
      }
      
    func loadTodos() {
        coreDataService.fetchTodos(completion: { [weak self] todos in
            self?.todos = todos
            
            if !todos.isEmpty {
                self?.retriveTodos()
                return
            }
            
            self?.apiService.getData { [weak self] array in
                self?.todos = array
                self?.coreDataService.downloadTodos(todos: self?.todos ?? [])
                
                self?.retriveTodos()
            }
        })
    }
    
    func createToDo(todo: ToDoEntity) {
        self.coreDataService.createToDo(todo: ToDoEntity(id: findNextId(), todo: todo.todo, description: todo.description, completed: todo.completed)) { [weak self] in
            self?.coreDataService.fetchTodos(completion: { [weak self] todos in
                self?.todos = todos
                
                self?.retriveTodos()
            })
        }
    }
    
    private func fetchTodos() {
        self.coreDataService.fetchTodos(completion: { [weak self] todos in
            self?.todos = todos
            
            self?.retriveTodos()
        })
    }
    
    func updateToDo(todo: ToDoEntity) {
        self.coreDataService.updateToDo(todo: todo) { [weak self] in
            self?.fetchTodos()
        }
    }
    
    func deleteFromDb(todo: ToDoEntity) {
        self.coreDataService.deleteToDo(todo: todo) {  [weak self] in
            self?.fetchTodos()
        }
    }
    
    func retriveTodos() {
        DispatchQueue.main.async {
            self.presenter?.presentTodos(todos: self.todos)
        }
    }
    
    func findNextId() -> Int {
        return (self.todos.map { $0.id }.max() ?? 0) + 1
    }
}
