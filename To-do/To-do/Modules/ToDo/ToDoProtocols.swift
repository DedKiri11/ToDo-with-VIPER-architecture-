//
//  ToDoProtocols.swift
//  To-do
//
//  Created by Кирилл Зезюков on 28.08.2024.
//

import Foundation

protocol ToDoViewControllerProtocol: AnyObject {
    func displayTodos(_ todos: [ToDoEntity])
}

protocol ToDoPresenterProtocol: AnyObject {
    func deleteToDo(todo: ToDoEntity)
    func updateToDo(todo: ToDoEntity)
    func addToDo(todo: ToDoEntity)
    func viewWillAppear()
    func presentTodos(todos: [ToDoEntity])
}

protocol ToDoInteractorProtocol: AnyObject {
    func createToDo(todo: ToDoEntity)
    func loadTodos()
    func deleteFromDb(todo: ToDoEntity)
    func retriveTodos()
    func updateToDo(todo: ToDoEntity)
}

protocol ToDoRouterProtocol: AnyObject {
    static func createModule() -> ToDoViewController
}

protocol CoreDataServiceProtocol: AnyObject {
    func createToDo(todo: ToDoEntity, completion: @escaping () -> Void)
    func fetchTodos(completion: @escaping ([ToDoEntity]) -> Void)
    func downloadTodos(todos: [ToDoEntity])
    func updateToDo(todo: ToDoEntity, completion: @escaping () -> Void)
    func deleteToDo(todo: ToDoEntity, completion: @escaping () -> Void)
}

protocol ToDoAPIServiceProtocol: AnyObject {
    func getData(completion: @escaping (([ToDoEntity])->()))
}
