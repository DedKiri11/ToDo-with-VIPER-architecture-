//
//  HTTPResponse.swift
//  To-do
//
//  Created by Кирилл Зезюков on 29.08.2024.
//

import Foundation

struct HTTPResponse: Decodable {
    var todos: [ToDoDTO]
}

struct ToDoDTO: Decodable {
    var id: Int
    var todo: String
    var completed: Bool
    var date: Date = .now
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case todo = "todo"
        case completed = "completed"
    }
    
    static var `default` = ToDoEntity(id: 0, todo: "", description: "", completed: false)
}
