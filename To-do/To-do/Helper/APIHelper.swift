//
//  APIHelper.swift
//  To-do
//
//  Created by Кирилл Зезюков on 29.08.2024.
//

import Foundation

class APIHelper {
    enum APIErrors: String {
        case badURL = "Bad URL"
        case badRequest = "Bad Request"
        case dataMissing = "Data missing"
    }
    
    static func sendRequest(completion: ((Data)->())? = nil) {
        let baseURL = "https://dummyjson.com/todos"
        guard let url = URL(string: baseURL) else {
            print(APIErrors.badURL.rawValue)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(APIErrors.badRequest.rawValue)
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {
                print(APIErrors.dataMissing.rawValue)
                return
            }
            
            completion?(data)
        }
        
        task.resume()
    }
}

