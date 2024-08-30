//
//  CalendarComponents.swift
//  Sketchy
//
//  Created by nabbit on 30/08/2024.
//

import Foundation

func checkTodayIsSpecialDay(day: Int, month: Int) -> Bool {
       let calendar = Calendar.current
       let today = Date()
       
       // Create date components for April 16th
       let targetComponents = DateComponents(month: month, day: day)
       
       // Extract current month and day components
       let todayComponents = calendar.dateComponents([.month, .day], from: today)
       
       // Compare the components
       return todayComponents.month == targetComponents.month && todayComponents.day == targetComponents.day
}
