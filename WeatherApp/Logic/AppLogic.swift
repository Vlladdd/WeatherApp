//
//  AppLogic.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 23.03.2022.
//

import Foundation

//struct that represents logic of app
struct AppLogic: Codable {
    
    //MARK: - Properties
    
    var cities: [City] = []
    
    //builder
    private let temperatureBuilder = ConcreteTemperatureBuilder()
    
    //key for UserDefaults
    static private let userKey = "UserData"
    
    enum CodingKeys: String, CodingKey {
        case cities
    }
    
    //MARK: - Inits
    
    init() {
        if let jsonData = UserDefaults.standard.data(forKey: AppLogic.userKey), let data = try? JSONDecoder().decode(AppLogic.self, from: jsonData) {
            self.cities = data.cities
        }
        else {
            //randomData()
        }
    }
    
    //MARK: - Functions
    
    //just random data
    private mutating func randomData() {
        addCity(name: "Kyiv", type: .big)
        addCity(name: "Lviv", type: .medium)
        addCity(name: "London", type: .small)
        var dateComponents = DateComponents(year: 2020, month: 3, day: 1)
        let calendar = Calendar(identifier: .gregorian)
        var date = calendar.date(from: dateComponents)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 22)
        addTemperatureToCity(name: "Kyiv", date: date!)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 15)
        addTemperatureToCity(name: "Lviv", date: date!)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 10)
        addTemperatureToCity(name: "London", date: date!)
        dateComponents.month = 4
        date = calendar.date(from: dateComponents)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 19)
        addTemperatureToCity(name: "Kyiv", date: date!)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 16)
        addTemperatureToCity(name: "Lviv", date: date!)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 11)
        addTemperatureToCity(name: "London", date: date!)
        dateComponents.month = 5
        date = calendar.date(from: dateComponents)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 23)
        addTemperatureToCity(name: "Kyiv", date: date!)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 17)
        addTemperatureToCity(name: "Lviv", date: date!)
        temperatureBuilder.produceDate(value: date!)
        temperatureBuilder.produceValue(value: 12)
        addTemperatureToCity(name: "London", date: date!)
        if let data = try? toJson() {
            UserDefaults.standard.set(data, forKey: AppLogic.userKey)
        }
    }
    
    //encodes
    func toJson() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    //MARK: - City
    
    mutating func addCity(name: String, type: CityType) {
        
        if let index = cities.firstIndex(where: {$0.name == name}) {
            cities[index].type = type
        }
        else {
            cities.append(City(name: name, id: name, type: type))
        }
    }
    
    mutating func removeCity(name: String) {
        if let index = cities.firstIndex(where: {$0.name == name}){
            cities.remove(at: index)
        }
    }
    
    //MARK: - Temperature
    
    mutating func addTemperatureToCity(name: String, date: Date) {
        
        if let index = cities.firstIndex(where: {$0.name == name}) {
            if let tempIndex = cities[index].temperatureData.firstIndex(where: {$0.date.toStringDateHM == date.toStringDateHM}) {
                cities[index].temperatureData[tempIndex] = temperatureBuilder.retrieveProduct()
            }
            else {
                cities[index].temperatureData.append(temperatureBuilder.retrieveProduct())
            }
        }
        
    }
    
    mutating func addTemperatureToCity(name: String, temperatureData: [Temperature]) {
        
        if let index = cities.firstIndex(where: {$0.name == name}) {
            for temp in temperatureData {
                if let tempIndex = cities[index].temperatureData.firstIndex(where: {$0.date.toStringDateHM == temp.date.toStringDateHM}) {
                    cities[index].temperatureData[tempIndex] = temp
                }
                else {
                    cities[index].temperatureData.append(temp)
                }
            }
        }
        
    }
    
    mutating func removeTemperatureFromCity(name: String, indexSet: IndexSet) {
        if let index = cities.firstIndex(where: {$0.name == name}) {
            var datesToRemove = [String]()
            cities[index].temperatureData.sort(by: {$0.date > $1.date})
            for tempIndex in indexSet {
                datesToRemove.append(cities[index].temperatureData[tempIndex].date.toString)
            }
            for temp in cities[index].temperatureData {
                if datesToRemove.contains(temp.date.toString){
                    if let tempIndex = cities[index].temperatureData.firstIndex(where: {$0.date == temp.date}) {
                        cities[index].temperatureData.remove(at: tempIndex)
                    }
                }
            }
        }
    }
    
    func addDateToTemperature(value: Date) {
        temperatureBuilder.produceDate(value: value)
    }
    
    func addValueToTemperature(value: Int) {
        temperatureBuilder.produceValue(value: value)
    }
    
    func addWindToTemperature(value: Double) {
        temperatureBuilder.produceWindData(value: value)
    }
    
    func addVisibilityToTemperature(value: Int) {
        temperatureBuilder.produceVisibilityData(value: value)
    }
    
    func addCloudsToTemperature(value: Int) {
        temperatureBuilder.produceCloudsData(value: value)
    }
    
    func addAdditionalDataToTemperature() {
        temperatureBuilder.addAdditionalData()
    }
    
}
