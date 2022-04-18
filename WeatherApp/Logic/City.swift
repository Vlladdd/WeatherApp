//
//  City.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 09.04.2022.
//

import Foundation

//struct that represents city
struct City: Identifiable, Codable{
    
    //MARK: - Properties
    
    let name: String
    let id: String
    
    var type: CityType
    var temperatureData: [Temperature] = []
    
    //all available years in temperatureData
    var years: [Int] {
        var result = [Int]()
        for temp in temperatureData {
            if !result.contains(temp.date.get(.year)){
                result.append(temp.date.get(.year))
            }
        }
        return result
    }
    
    //all available dates in temperatureData
    var dates: [Date] {
        var result = [Date]()
        for temp in temperatureData {
            let dateComponents = temp.date.get(.year, .month, .day)
            let calendar = Calendar(identifier: .gregorian)
            let date = calendar.date(from: dateComponents)
            if let date = date {
                result.append(date)
            }
        }
        return result.unique
    }
    
    //MARK: - Functions
    
    //all available temperatureData with different times in date
    func  getAllData(from date: Date) -> [Temperature] {
        var result = [Temperature]()
        for temp in temperatureData {
            if temp.date.toString == date.toString {
                result.append(temp)
            }
        }
        return result
    }
    
    //all available times in date
    func getAllTimes(in temperatureData: [Temperature]) -> [String] {
        var result = [String]()
        for temp in temperatureData {
            result.append(temp.date.toTimeString)
        }
        return result
    }
    
    //avg data for day
    func getAvgTempDataForDay(date: String) -> Temperature {
        let tempBuilder = ConcreteTemperatureBuilder()
        var result = Temperature()
        var weatherIcons = [String:Int]()
        var avgClouds = [Int:Int]()
        var avgTemp = (value: 0,count: 0)
        var avgWindSpeed = (value: 0.0,count: 0)
        var avgVisibility = (value: 0,count: 0)
        var tempDate = Date()
        for temp in temperatureData {
            if temp.date.toString == date {
                tempDate = temp.date
                avgTemp.value += temp.value
                avgTemp.count += 1
                if let icon = temp.additionalData?.weather?[0].icon {
                    if weatherIcons[icon] != nil {
                        weatherIcons[icon]! += 1
                    }
                    else {
                        weatherIcons[icon] = 0
                    }
                }
                if let cloudsValue = temp.additionalData?.weather?.first?.id{
                    if avgClouds[cloudsValue] != nil {
                        avgClouds[cloudsValue]! += 1
                    }
                    else {
                        avgClouds[cloudsValue] = 0
                    }
                }
                if let visibility = temp.additionalData?.visibility {
                    avgVisibility.value += visibility
                    avgVisibility.count += 1
                }
                if let windSpeed = temp.additionalData?.wind?.speed {
                    avgWindSpeed.value += windSpeed
                    avgWindSpeed.count += 1
                }
            }
        }
        tempBuilder.produceDate(value: tempDate)
        tempBuilder.produceValue(value: avgTemp.value / avgTemp.count)
        if let avgCloudStatus = avgClouds.max(by: {$0.value < $1.value}) {
            tempBuilder.produceCloudsData(value: avgCloudStatus.key)
        }
        if avgVisibility.count > 0 {
            tempBuilder.produceVisibilityData(value: avgVisibility.value / avgVisibility.count)
        }
        if avgWindSpeed.count > 0 {
            tempBuilder.produceWindData(value: avgWindSpeed.value / Double(avgWindSpeed.count))
        }
        if let weatherIcon = weatherIcons.max(by: {$0.value < $1.value}) {
            tempBuilder.produceWeatherIcon(value: weatherIcon.key)
        }
        tempBuilder.addAdditionalData()
        result = tempBuilder.retrieveProduct()
        return result
    }
    
    //data in chosen date with chosen time
    func getData(from date: Date, and time: String) -> Temperature?{
        for temp in temperatureData {
            if temp.date.toString + temp.date.toTimeString == date.toString + time{
                getLog(date: date, value: temp.value)
                return temp
            }
        }
        return nil
    }
    
    //average temperature of the year
    func avgTempTotal(temperatureFormat: ValueContext, year: Int) -> String {
        var result = 0
        var dates = Set<String>()
        for temp in temperatureData {
            if temp.date.get(.year) == year {
                dates.insert(temp.date.toString)
            }
        }
        for date in dates {
            result += getAvgTempDataForDay(date: date).value
        }
        if dates.count > 0 {
            return temperatureFormat.getTemperatureData(value: result / dates.count)
        }
        else {
            return "No value"
        }
    }
    
    //average temperature for season in the year
    func getAvgTemp(temperatureFormat: ValueContext, seasonType: SeasonType, year: Int) -> String{
        var monthNames = [Int]()
        var result = 0
        var dates = Set<String>()
        switch seasonType {
        case .winter:
            monthNames = [12, 1, 2]
        case .spring:
            monthNames = [3, 4, 5]
        case .summer:
            monthNames = [6, 7, 8]
        case .autumn:
            monthNames = [9, 10, 11]
        }
        for temp in temperatureData {
            if monthNames.contains(temp.date.get(.month)) && temp.date.get(.year) == year{
                dates.insert(temp.date.toString)
            }
        }
        for date in dates {
            result += getAvgTempDataForDay(date: date).value
        }
        if dates.count > 0 {
            getLog(year: year, value: result / dates.count, seasonType: seasonType)
            return temperatureFormat.getTemperatureData(value: result / dates.count)
        }
        else {
            return "No value"
        }
    }
    
    //gets some log after getting info about temperature
    func getLog(year: Int, value: Int, seasonType: SeasonType) {
        
        let temperatureDecorator = TemperatureDecorator(YearInfo(year: year), value: value)
        let cityDecorator = CityDecorator(temperatureDecorator, cityName: self.name)
        let seasonDecorator = SeasonDecorator(cityDecorator, season: seasonType)
        InfoDecoratorClient.result(component: seasonDecorator)
    }
    
    func getLog(date: Date, value: Int) {
        
        let temperatureDecorator = TemperatureDecorator(DateInfo(date: date), value: value)
        let cityDecorator = CityDecorator(temperatureDecorator, cityName: self.name)
        InfoDecoratorClient.result(component: cityDecorator)
    }
    
}
