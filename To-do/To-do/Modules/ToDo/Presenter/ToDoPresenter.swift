//
//  ToDoPresenter.swift
//  To-do
//
//  Created by Кирилл Зезюков on 28.08.2024.
//

import UIKit

final class ToDoPresenter: ToDoPresenterProtocol {
    weak var view: ToDoViewControllerProtocol?
    var interactor: ToDoInteractorProtocol?
    
    func viewWillAppear() {
        interactor?.loadTodos()
    }
    
    func addToDo(todo: ToDoEntity) {
        interactor?.createToDo(todo: todo)
    }
    
    func deleteToDo(todo: ToDoEntity) {
        interactor?.deleteFromDb(todo: todo)
    }
    
    func updateToDo(todo: ToDoEntity) {
        interactor?.updateToDo(todo: todo)
    }
    
    func presentTodos(todos: [ToDoEntity]) {
        let sortedTodos = todos.sorted { $0.date > $1.date }
        view?.displayTodos(sortedTodos)
    }
}
