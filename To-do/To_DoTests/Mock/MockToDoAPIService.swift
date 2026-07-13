//
//  MockToDoAPIService.swift
//  To_do
//
//  Created by Кирилл Зезюков on 13.07.2026.
//

import Foundation
@testable import To_do

final class MockToDoAPIService: ToDoAPIServiceProtocol{
    private var stubbedData: [ToDoEntity]
    
    init(stub: [ToDoEntity] = []) {
        self.stubbedData = stub
    }
    
    func getData(completion: @escaping (([ToDoEntity]) -> ())) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            completion(self.stubbedData)
        }
    }
}
