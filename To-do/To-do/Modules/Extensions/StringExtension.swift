//
//  StringExtension.swift
//  To_do
//
//  Created by Кирилл Зезюков on 13.07.2026.
//

import Foundation

extension String {
    // MARK: - Screen Titles
    static var mainScreenTitle: String {
        return NSLocalizedString("mainScreenTitle", comment: "")
    }
    
    // MARK: - Buttons
    static var backButtonTitle: String {
        return NSLocalizedString("backButtonTitle", comment: "")
    }
    
    static var delete: String {
        return NSLocalizedString("delete", comment: "")
    }
    
    static var search: String {
        return NSLocalizedString("search", comment: "")
    }
    
    static var update: String {
        return NSLocalizedString("update", comment: "")
    }
    
    static var share: String {
        return NSLocalizedString("share", comment: "")
    }
    
    // MARK: - Labels
    static var numberOfTasks: String {
        return NSLocalizedString("numberOfTasks", comment: "")
    }
    
    // MARK: - Status
    static var complete: String {
        return NSLocalizedString("complete", comment: "")
    }
    
    static var notComplete: String {
        return NSLocalizedString("notComplete", comment: "")
    }
    
    // MARK: - Formats
    static var dateMask: String {
        return NSLocalizedString("dateMask", comment: "")
    }
    
    // MARK: - Shared Detail Labels
    static var sharedTitle: String {
        return NSLocalizedString("sharedTitle", comment: "")
    }
    
    static var sharedDescription: String {
        return NSLocalizedString("sharedDescription", comment: "")
    }
    
    static var sharedDate: String {
        return NSLocalizedString("sharedDate", comment: "")
    }
    
    static var sharedStatus: String {
        return NSLocalizedString("sharedStatus", comment: "")
    }
}
