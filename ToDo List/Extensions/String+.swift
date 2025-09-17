//
//  String+.swift
//  ToDo List
//
//  Created by Dmitriy Kalyakin on 18/9/25.
//

import Foundation

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.date(from: self)
    }
}
