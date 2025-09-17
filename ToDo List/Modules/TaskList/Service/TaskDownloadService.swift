//
//  TodosRemoteService.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import Foundation

protocol TaskDownloadServicing {
    func fetchData(completion: @escaping (Result<TaskList, Error>) -> Void)
}

final class TaskDownloadService: TaskDownloadServicing {
	private let session: URLSession
	private let decoder: JSONDecoder
    
    private let urlString = "https://dummyjson.com/todos"

	init(session: URLSession = .shared) {
		self.session = session
		self.decoder = JSONDecoder()
	}
    
    func fetchData(completion: @escaping (Result<TaskList, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Wrong URL", code: 0)))
			return
		}
        
		session.dataTask(with: URLRequest(url: url)) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
			guard let data, let self = self else {
				completion(.failure(NSError(domain: "No data", code: 0)))
				return
			}
            
			do {
				let response = try self.decoder.decode(TaskList.self, from: data)
				completion(.success(response))
			} catch {
				completion(.failure(error))
			}
		}.resume()
	}
}


