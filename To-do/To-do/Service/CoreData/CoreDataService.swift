//
//  CoreDataService.swift
//  To-do
//
//  Created by Кирилл Зезюков on 29.08.2024.
//

import CoreData
import UIKit

final class CoreDataService: CoreDataServiceProtocol {
    static var shared = CoreDataService()
    
    private lazy var backgroundContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = PersistenseService.context
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()
    
    private func saveChain(context: NSManagedObjectContext, completion: (() -> Void)? = nil) {
        context.perform {
            guard context.hasChanges else {
                if let parent = context.parent {
                    parent.perform {
                        if parent.hasChanges {
                            do {
                                try parent.save()
                            } catch {
                                let nserror = error as NSError
                                fatalError("Unresolved error saving parent \(nserror), \(nserror.userInfo)")
                            }
                        }
                        completion?()
                    }
                } else {
                    completion?()
                }
                return
            }
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error saving child \(nserror), \(nserror.userInfo)")
            }
            
            if let parent = context.parent {
                parent.perform {
                    if parent.hasChanges {
                        do {
                            try parent.save()
                        } catch {
                            let nserror = error as NSError
                            fatalError("Unresolved error saving parent \(nserror), \(nserror.userInfo)")
                        }
                    }
                    completion?()
                }
            } else {
                completion?()
            }
        }
    }
    
    // MARK: - Create
    func createToDo(todo: ToDoEntity, completion: @escaping () -> Void) {
        backgroundContext.perform {
            let newTodo = ToDo(context: self.backgroundContext)
            newTodo.id = Int64(todo.id)
            newTodo.todo = todo.todo
            newTodo.todoDescription = todo.description
            newTodo.completed = todo.completed
            newTodo.date = Date()
            
            self.saveChain(context: self.backgroundContext) {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    // MARK: - Read
    func fetchTodos(completion: @escaping ([ToDoEntity]) -> Void) {
        backgroundContext.perform {
            let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
            do {
                let todos = try self.backgroundContext.fetch(fetchRequest)
                let toDoEntities = todos.map { EntityMapper.toToDoEntity($0) }
                DispatchQueue.main.async {
                    completion(toDoEntities)
                }
            } catch {
                print("Error fetching todos: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    // MARK: - Read
    private func fetchTodoObjectID(by id: Int64, completion: @escaping (NSManagedObjectID?) -> Void) {
        backgroundContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
            fetchRequest.predicate = NSPredicate(format: "id == %d", id)
            fetchRequest.fetchLimit = 1
            do {
                let results = try self.backgroundContext.fetch(fetchRequest)
                let objectID = (results.first as? NSManagedObject)?.objectID
                DispatchQueue.main.async {
                    completion(objectID)
                }
            } catch {
                print("Error fetching todo by id: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    // MARK: - insert
    func downloadTodos(todos: [ToDoEntity]) {
        backgroundContext.perform {
            for entity in todos {
                let todo = ToDo(context: self.backgroundContext)
                todo.id = Int64(entity.id)
                todo.todo = entity.todo
                todo.todoDescription = entity.description
                todo.completed = entity.completed
                todo.date = entity.date
            }
            self.saveChain(context: self.backgroundContext, completion: nil)
        }
    }
    
    // MARK: - Update
    func updateToDo(todo: ToDoEntity, completion: @escaping () -> Void) {
        backgroundContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
            fetchRequest.predicate = NSPredicate(format: "id == %d", Int64(todo.id))
            fetchRequest.fetchLimit = 1
            do {
                if let objectToUpdate = try self.backgroundContext.fetch(fetchRequest).first as? ToDo {
                    objectToUpdate.todo = todo.todo
                    objectToUpdate.completed = todo.completed
                    objectToUpdate.todoDescription = todo.description
                    
                    self.saveChain(context: self.backgroundContext) {
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                } else {
                    print("No object found to update for id \(todo.id)")
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            } catch {
                print("Error to update: \(error)")
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
    
    // MARK: - Delete
    func deleteToDo(todo: ToDoEntity, completion: @escaping () -> Void) {
        backgroundContext.perform {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ToDo")
            fetchRequest.predicate = NSPredicate(format: "id == %d", Int64(todo.id))
            fetchRequest.fetchLimit = 1
            do {
                if let objectToDelete = try self.backgroundContext.fetch(fetchRequest).first as? NSManagedObject {
                    self.backgroundContext.delete(objectToDelete)
                    self.saveChain(context: self.backgroundContext) {
                        completion()
                    }
                } else {
                    print("No object found to delete for id \(todo.id)")
                }
            } catch {
                print("Error to delete \(error)")
            }
        }
    }
}

