//
//  Enums.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 09.04.2022.
//

import Foundation

//MARK: - Some useful Enums

enum ValueStyle: String, Codable {
    
    case metric
    case standard
    case imperial
    
}

enum SeasonType: String, Codable {
    
    case winter
    case spring
    case summer
    case autumn
    
}

enum CityType: String, CaseIterable, Identifiable, Codable {
    
    case small
    case medium
    case big
    
    var id: String {
        return self.rawValue
    }
    
}

enum DataType: String, Codable {
    
    case local
    case server
    
}

enum CloudStatus: String, Codable, Identifiable {
    
    case sun
    case clouds
    case rain
    case storm
    case snow
    case mist
    
    var id: String {
        return self.rawValue
    }
}

enum Month: String, Codable {
    
    case january
    case february
    case march
    case april
    case may
    case june
    case jule
    case august
    case september
    case october
    case november
    case december
    
}

enum LoadError: Error {
    
    case somethingWentWrong
    
}
