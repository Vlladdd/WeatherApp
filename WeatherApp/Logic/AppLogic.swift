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
    
    //key for FileManager
    static private let userKey = "UserData"
    
    //url for FileManager
    static private let fileManagerURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(AppLogic.userKey)
    
    
    enum CodingKeys: String, CodingKey {
        case cities
    }
    
    //MARK: - Inits
    
    init() {
        if let fileManagerURL = AppLogic.fileManagerURL, let jsonData = try? Data(contentsOf: fileManagerURL), let data = try? JSONDecoder().decode(AppLogic.self, from: jsonData) {
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
            if let fileManagerURL = AppLogic.fileManagerURL {
                try? data.write(to: fileManagerURL)
            }
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
    
    mutating func removeTemperatureFromCity(name: String, indexSet: IndexSet) {
        if let index = cities.firstIndex(where: {$0.name == name}) {
            var datesToRemove = [String]()
            for tempIndex in indexSet {
                datesToRemove.append(cities[index].temperatureData[tempIndex].date.toString)
            }
            for temp in cities[index].temperatureData {
                if datesToRemove.contains(temp.date.toString){
                    if let tempIndex = cities[index].temperatureData.firstIndex(where: {$0.date == temp.date}) {
                        cities[index].temperatureData.remove(at: tempIndex)
                    }
                    if let dateIndex = cities[index].dates.firstIndex(where: {$0.toString == temp.date.toString}) {
                        cities[index].dates.remove(at: dateIndex)
                    }
                }
            }
            cities[index].getYears()
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
