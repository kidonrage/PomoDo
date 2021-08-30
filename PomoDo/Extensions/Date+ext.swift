//
//  Date+ext.swift
//  PomoDo
//
//  Created by Aura on 29.08.2021.
//

import Foundation

extension Date {

    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
   }

}
