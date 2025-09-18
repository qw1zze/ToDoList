//
//  UpdateTableModel.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import Foundation

enum UpdateTableModel {
    case delete(_ indexPath: IndexPath, tasks: [Task])
    case reload
}
