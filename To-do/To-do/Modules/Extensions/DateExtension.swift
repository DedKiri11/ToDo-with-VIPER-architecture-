//
//  DateExtension.swift
//  To-do
//
//  Created by Александра Тимонова on 08.07.2026.
//
import Foundation

extension Date {
    func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("dateMask", comment: "")
        return dateFormatter.string(from: self)
    }
}
