//
//  TemperatureBuilder.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 28.03.2022.
//

import Foundation

//MARK: - Temperature

//struct that represents temperature
struct Temperature: Codable {

    var date: Date = Date()
    var value: Int = 0
    var additionalData: AdditionalData? = nil
    
    // just random temperature data
    static func getRandomTemperatureData() -> [Temperature] {
        
        var temperatureData = [Temperature]()
        let temperatureBuilder = ConcreteTemperatureBuilder()
        var dateComponents = DateComponents(year: 2020, month: 3, day: 1)
        let calendar = Calendar(identifier: .gregorian)
        var date = calendar.date(from: dateComponents)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 22)
        temperatureData.append(temperatureBuilder.retrieveProduct())
        dateComponents.month = 4
        date = calendar.date(from: dateComponents)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 23)
        temperatureData.append(temperatureBuilder.retrieveProduct())
        dateComponents.month = 5
        date = calendar.date(from: dateComponents)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 24)
        temperatureData.append(temperatureBuilder.retrieveProduct())
        
        return temperatureData
    }
    
}

//MARK: - Temperature Builder

//interface for temperature builder
protocol TemperatureBuilder {

    func produceDate(value: Date)
    func produceValue(value: Int)
    func produceAdditionalData(value: AdditionalData)
    func produceWeatherIcon(value: String)
    func produceWindData(value: Double)
    func produceVisibilityData(value: Int)
    func produceCloudsData(value: Int)
    func addAdditionalData()
}

//builder of the temperature
class ConcreteTemperatureBuilder: TemperatureBuilder {

    private var product = Temperature()
    private var additionalData = AdditionalData()

    func reset() {
        product = Temperature()
        additionalData = AdditionalData()
    }

    func produceDate(value: Date) {
        product.date = value
    }

    func produceValue(value: Int) {
        product.value = value
    }

    func produceAdditionalData(value: AdditionalData) {
        product.additionalData = value
    }
    
    func produceWeatherIcon(value: String) {
        if let _ = additionalData.weather?[0] {
            additionalData.weather![0].icon = value
        }
        else {
            additionalData.weather = [WeatherT(icon: value)]
        }
    }
    
    func produceWindData(value: Double) {
        additionalData.wind = WindT(speed: value, deg: nil)
    }
    
    func produceVisibilityData(value: Int) {
        additionalData.visibility = value
    }
    
    func produceCloudsData(value: Int) {
        if let _ = additionalData.weather?[0] {
            additionalData.weather![0].id = value
        }
        else {
            additionalData.weather = [WeatherT(id: value)]
        }
    }
    
    func addAdditionalData() {
        product.additionalData = additionalData
    }

    func retrieveProduct() -> Temperature {
        let result = self.product
        reset()
        return result
    }
}

//MARK: - Temperature data from server

//this is done just to let swift decode data and not decode data from server by yourself
//struct that represents additional data
struct AdditionalData: Identifiable, Codable {
    
    var coord: CoordT? = nil
    var weather: [WeatherT]? = nil
    var base: String? = nil
    var main: MainT? = nil
    var visibility: Int? = nil
    var wind: WindT? = nil
    var clouds: CloudsT? = nil
    var dt: Int? = nil
    var sys: SysT? = nil
    var timezone: Int? = nil
    var id: Int? = nil
    var name: String? = nil
    var cod: Int? = nil
    
}

//struct that represents coordinates of city
struct CoordT: Codable {
    
    let lon: Double?
    let lat: Double?
    
}

//struct that represents main temperature data
struct MainT: Codable {
    
    let temp: Double?
    let feels_like: Double?
    let temp_min: Double?
    let temp_max: Double?
    let pressure: Int?
    let humidity: Int?
    
}

//struct that represents wind data
struct WindT: Codable {
    
    let speed: Double?
    let deg: Int?
    
}

//struct that represents clouds data
struct CloudsT: Codable {
    
    let all: Int?
    
}

//struct that represents system data
struct SysT: Codable {
    
    let type: Int?
    let id: Int?
    let message: Double?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
    
}

//struct that represents weather data
struct WeatherT: Codable {
    
    var id: Int? = nil
    var main: String? = nil
    var description: String? = nil
    var icon: String? = nil
    
}
