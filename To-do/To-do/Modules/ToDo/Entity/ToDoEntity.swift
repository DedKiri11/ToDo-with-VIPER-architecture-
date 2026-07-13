//
//  ToDoEntity.swift
//  To-do
//
//  Created by Кирилл Зезюков on 28.08.2024.
//

import Foundation

struct ToDoEntity: Decodable, Equatable {
    var id: Int
    var todo: String
    var description: String
    var completed: Bool
    var date: Date = .now
    
    static var `default` = ToDoEntity(id: 0, todo: "", description: "", completed: false)
}
