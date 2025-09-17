//
//  Date+.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 17/9/25.
//

import Foundation

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.string(from: self)
    }
}
