//
//  DateFunctions.swift
//  WOTS
//
//  Created by Max Freundlich on 5/17/17.
//  Copyright © 2017 Learning Curve. All rights reserved.
//

import Foundation
import UIKit

func getWeekDaysInEnglish() -> [String] {
    let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
    calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
    return calendar.weekdaySymbols
}

enum SearchDirection {
    case Next
    case Previous
    
    var calendarOptions: NSCalendar.Options {
        switch self {
        case .Next:
            return .matchNextTime
        case .Previous:
            return [.searchBackwards, .matchNextTime]
        }
    }
}

func getDateByWeekday(direction: SearchDirection, _ dayName: String, considerToday consider: Bool = false) -> NSDate {
    let weekdaysName = getWeekDaysInEnglish()
    
    assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
    
    let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
    
    let today = NSDate()
    
    let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
    
    if consider && calendar.component(.weekday, from: today as Date) == nextWeekDayIndex {
        return today
    }
    
    let nextDateComponent = NSDateComponents()
    nextDateComponent.weekday = nextWeekDayIndex
    
    
    let date = calendar.nextDate(after: today as Date, matching: nextDateComponent as DateComponents, options: direction.calendarOptions)
    return date! as NSDate
}
