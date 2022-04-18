//
//  Extensions.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 08.04.2022.
//

import Foundation

//MARK: - Some useful extensions

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
    
    var toString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df.string(from: self)
    }
    
    var toTimeString: String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        return df.string(from: self)
    }
    
    var toStringDateHM: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df.string(from: self)
    }
}

extension Double {
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension StringProtocol {
    
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
    
}

extension Array where Element: Hashable {
    
    var unique: Self {
        var set = Set<Element>()
        return filter{ set.insert($0).inserted }
    }
}
