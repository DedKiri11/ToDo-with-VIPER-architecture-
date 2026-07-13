//
//  ToDoService.swift
//  To-do
//
//  Created by Кирилл Зезюков on 29.08.2024.
//

import Foundation

final class ToDoAPIService: ToDoAPIServiceProtocol {
    static var shared = ToDoAPIService()
    func getData(completion: @escaping (([ToDoEntity])->())) {
        APIHelper.sendRequest { data in
            guard let response = try? JSONDecoder().decode(HTTPResponse.self, from: data) else { return }
            completion(EntityMapper.toToDoEntity(response.todos))
        }
    }
}
