//
//  InfoDecorator.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 24.03.2022.
//

import Foundation

//MARK: - Decorator of the log

//interface for log info
protocol Info {
    
    func operation() -> String
    
}

//class for decorators
class InfoDecorator: Info {

    private var info: Info

    init(_ info: Info) {
        self.info = info
    }

    func operation() -> String {
        return info.operation()
    }
}

class InfoDecoratorClient {

    static func result(component: Info) {
        print("Log: " + component.operation())
    }

}

//MARK: - Info

class CityInfo: Info {
    
    private var cityName: String
    
    init(name: String) {
        self.cityName = name
    }

    func operation() -> String {
        return "City:" + cityName
    }
}

class SeasonInfo: Info {
    
    private var season: SeasonType
    
    init(season: SeasonType) {
        self.season = season
    }

    func operation() -> String {
        return "Season:" + season.rawValue
    }
}

class YearInfo: Info {
    
    private var year: Int
    
    init(year: Int) {
        self.year = year
    }

    func operation() -> String {
        return "Year:" + String(year)
    }
}

class DateInfo: Info {
    
    private var date: Date
    
    init(date: Date) {
        self.date = date
    }

    func operation() -> String {
        return "Date:" + date.toStringDateHM
    }
}

class TemperatureInfo: Info {
    
    private var value: Int
    
    init(value: Int) {
        self.value = value
    }

    func operation() -> String {
        return "Temperature:" + String(value)
    }
}

//MARK: - Decorators

class CityDecorator: InfoDecorator {
    
    private var cityName: String
    
    init(_ info: Info, cityName: String) {
        self.cityName = cityName
        super.init(info)
    }

    override func operation() -> String {
        return "City:" + cityName + " " + super.operation()
    }
}

class SeasonDecorator: InfoDecorator {
    
    private var season: SeasonType
    
    init(_ info: Info, season: SeasonType ) {
        self.season = season
        super.init(info)
    }
    
    override func operation() -> String {
        return "Season:" + season.rawValue + " " + super.operation()
    }
}

class YearDecorator: InfoDecorator {
    
    private var year: Int
    
    init(_ info: Info, year: Int) {
        self.year = year
        super.init(info)
    }
    
    override func operation() -> String {
        return "Year:" + String(year) + " " + super.operation()
    }
}

class TemperatureDecorator: InfoDecorator {
    
    private var value: Int
    
    init(_ info: Info, value: Int) {
        self.value = value
        super.init(info)
    }
    
    override func operation() -> String {
        return "Temperature:" + String(value) + " " + super.operation()
    }
}

class DateDecorator: InfoDecorator {
    
    private var date: Date
    
    init(_ info: Info, date: Date) {
        self.date = date
        super.init(info)
    }
    
    override func operation() -> String {
        return "Date:" + date.toString + " " + super.operation()
    }
}
