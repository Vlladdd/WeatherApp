//
//  TemperatureStrategy.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 25.03.2022.
//

import Foundation

//MARK: - Value Format Strategy

struct ValueContext {

    private var strategy: ValueStrategy

    init(strategy: ValueStrategy) {
        self.strategy = strategy
    }

    mutating func update(strategy: ValueStrategy) {
        self.strategy = strategy
    }

    func getTemperatureData(value: Int) -> String {
        
        print("Calculating temperature in format")
        
        return strategy.getTemperatureData(value: value)
    }
    
    func getLengthData(value: Int) -> String {
        
        print("Calculating length in format")
        
        return strategy.getLengthData(value: value)
    }
    
    func getSpeedData(value: Double) -> String {
        
        print("Calculating speed in format")
        
        return strategy.getSpeedData(value: value)
    }

}

//interface for value format strategy
protocol ValueStrategy {
    
    func getTemperatureData(value: Int) -> String
    
    func getLengthData(value: Int) -> String
    
    func getSpeedData(value: Double) -> String
}

//MARK: - Metric Strategy

//by default value is in metric format
class MetricStrategy: ValueStrategy {
    
    func getTemperatureData(value: Int) -> String {
        return String(value) + " ℃"
    }
    
    func getLengthData(value: Int) -> String {
        return String(value) + " meter"
    }
    
    func getSpeedData(value: Double) -> String {
        return String(value.rounded(toPlaces: ValueStrategyConstants.digitsInDoubleAfterComa)) + " meter/sec"
    }
    
}

//MARK: - Imperial Strategy

class ImperialStrategy: ValueStrategy {
    
    func getTemperatureData(value: Int) -> String {
        return String((value * 9/5) + 32) + " ℉"
    }
    
    func getLengthData(value: Int) -> String {
        return String(value / 1609) + " miles"
    }
    
    func getSpeedData(value: Double) -> String {
        return String((value * 2.237).rounded(toPlaces: ValueStrategyConstants.digitsInDoubleAfterComa)) + " miles/hour"
    }
    
}

//MARK: - Standard Strategy

class StandardStrategy: ValueStrategy {
    
    func getTemperatureData(value: Int) -> String {
        return String(value + 273) + " K"
    }
    
    func getLengthData(value: Int) -> String {
        return String(value) + " meter"
    }
    
    func getSpeedData(value: Double) -> String {
        return String(value.rounded(toPlaces: ValueStrategyConstants.digitsInDoubleAfterComa)) + " meter/sec"
    }
    
}

//MARK: - Constants

private struct ValueStrategyConstants {
    
    static let digitsInDoubleAfterComa = 3
}
