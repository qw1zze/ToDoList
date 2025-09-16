//
//  TaskList.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 16/9/25.
//

struct TaskList: Decodable {
    let tasks: [Task]
    let total: Int
    let skip: Int
    let limit: Int
    
    enum CodingKeys: String, CodingKey {
        case tasks = "todos", total, skip, limit
    }
}
