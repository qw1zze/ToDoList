//
//  Task.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

import Foundation

struct Task: Decodable {
    let id: Int
    let title: String?
    let description: String?
    var completed: Bool
    let userId: Int
    let date: Date?
    
    enum CodingKeys: String,  CodingKey {
        case id, title = "todo", description, completed, userId, date
    }
}
