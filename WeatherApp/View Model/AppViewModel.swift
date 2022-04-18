//
//  AppViewModel.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 23.03.2022.
//

import SwiftUI

//class that represents view model of the app
class AppViewModel: ObservableObject {
    
    //MARK: - Properties
    
    @Published var citiesInfo = [CityInfo]()
    //using in CityDayView
    @Published var cloudsImage: UIImage?
    //current format of value
    @Published var valueFormat = ValueContext(strategy: MetricStrategy())
    //current format of temperature data
    @Published var dataContext = DataContext(strategy: ServerDataStrategy())
    
    @Published private var appLogic = AppLogic()
    
    @Published private(set) var dataServerIsAvailable = true
    
    var cities: [City] {
        appLogic.cities
    }
    
    //some city information, which is not a logic`s thing
    struct CityInfo: Identifiable {
        let cityName: String
        //for animation
        var offsetX: CGFloat = AppViewModelConstants.cityStartCoordinate
        var offsetY: CGFloat = AppViewModelConstants.cityStartCoordinate
        //waits for data
        var waitingForData = true
        var waitingForCityInfo = true
        var image: UIImage?
        var id: String {
            cityName
        }
    }
    
    //MARK: - Init
    
    init() {
        for city in appLogic.cities {
            citiesInfo.append(CityInfo(cityName: city.name))
        }
    }
    
    //MARK: - Functions
    
    //saves data to UserDefaults
    private func save() {
        if let data = try? appLogic.toJson() {
            UserDefaults.standard.set(data, forKey: AppViewModelConstants.userKey)
        }
    }
    
    //checks download status
    func checkCityStatus(name: String) -> Bool{
        if let index = self.citiesInfo.firstIndex(where: {$0.cityName == name}) {
            return !citiesInfo[index].waitingForData && !citiesInfo[index].waitingForCityInfo
        }
        return false
    }
    
    //gets data of all cities
    func getCitiesData() {
        for city in citiesInfo {
            if let index = citiesInfo.firstIndex(where: {$0.cityName == city.cityName}) {
                citiesInfo[index].waitingForData = true
                citiesInfo[index].waitingForCityInfo = true
                citiesInfo[index].offsetX = AppViewModelConstants.cityStartCoordinate
                citiesInfo[index].offsetY = AppViewModelConstants.cityStartCoordinate
            }
        }
        dataServerIsAvailable = true
        DispatchQueue.global().async {[weak self] in
            if let self = self {
                for city in self.appLogic.cities {
                    self.getCityData(name: city.name)
                }
            }
        }
    }
    
    func getCityData(name: String) {
        getCityInfo(name: name)
        dataContext.getData(cityName: name) {value, error in
            DispatchQueue.main.sync {[weak self] in
                if let self = self {
                    if let error = error {
                        if let _ = error as? URLError {
                            self.dataServerIsAvailable = false
                        }
                    }
                    else {
                        self.appLogic.addTemperatureToCity(name: name, temperatureData: value)
                    }
                    if let index = self.citiesInfo.firstIndex(where: {$0.cityName == name}) {
                        self.citiesInfo[index].waitingForData = false
                    }
                    self.save()
                }
            }
        }
    }
    
    
    //gets CityInfo data
    //currently just gets a random picture, but it should be a random picture of city
    //i just dont find a good api for that
    private func getCityInfo(name: String) {
        let seed = randomString(length: AppViewModelConstants.seedLength)
        let url = URL(string: "https://picsum.photos/seed/\(seed)/1000/1000")
        getData(from: url!) { data, response, error in
            guard let data = data, error == nil
            else {
                DispatchQueue.main.sync() {[weak self] in
                    if let self = self {
                        if let index = self.citiesInfo.firstIndex(where: {$0.cityName == name}) {
                            self.citiesInfo[index].waitingForCityInfo = false
                        }
                    }
                }
                return
            }
            DispatchQueue.main.sync() {[weak self] in
                if let self = self {
                    if let index = self.citiesInfo.firstIndex(where: {$0.cityName == name}) {
                        self.citiesInfo[index].image = UIImage(data: data)
                        self.citiesInfo[index].waitingForCityInfo = false
                    }
                }
            }
        }
    }
    
    //just for api of random image, for getting random image every time
    //in other words returns random seed
    private func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    //for server tasks
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    //makes weather icon in CityDayView
    func getCloudsImage(from weatherStatus: String) {
        cloudsImage = nil
        getData(from: URL(string: "https://openweathermap.org/img/wn/\(weatherStatus)@2x.png")!, completion: { data, response, error in
            guard let data = data, error == nil
            else {
                self.cloudsImage = nil
                return
            }
            DispatchQueue.main.sync() {[weak self] in
                if let self = self {
                    self.cloudsImage = UIImage(data: data)
                }
            }
        })
    }
    
    func getCloudStatus(from statusCode: Int) -> CloudStatus?{
        var cloudStatus: CloudStatus?
        switch statusCode {
        case _ where statusCode == 800:
            cloudStatus = .sun
        case _ where statusCode >= 801 && statusCode < 810:
            cloudStatus = .clouds
        case _ where statusCode >= 500 && statusCode < 600:
            cloudStatus = .rain
        case _ where statusCode >= 200 && statusCode < 300:
            cloudStatus = .storm
        case _ where statusCode >= 600 && statusCode < 700:
            cloudStatus = .snow
        case _ where statusCode >= 700 && statusCode < 800:
            cloudStatus = .mist
        default:
            cloudStatus = nil
        }
        return cloudStatus
    }
    
    //MARK: - Intents
    
    //MARK: - City
    
    func addCity(name: String, type: CityType) {
        appLogic.addCity(name: name, type: type)
        if !citiesInfo.contains(where: {$0.cityName == name}) {
            citiesInfo.append(CityInfo(cityName: name, waitingForData: false, waitingForCityInfo: false))
            DispatchQueue.global().async {[weak self] in
                if let self = self {
                    self.getCityData(name: name)
                }
            }
        }
        save()
    }
    
    func removeCity(name: String) {
        appLogic.removeCity(name: name)
        if let index = citiesInfo.firstIndex(where: {$0.cityName == name}) {
            citiesInfo.remove(at: index)
        }
        save()
    }
    
    func getCityImage(cityName: String) -> UIImage? {
        if let index = citiesInfo.firstIndex(where: {$0.cityName == cityName}) {
            return citiesInfo[index].image
        }
        return nil
    }
    
    func getCity(cityName: String) -> City? {
        if let index = cities.firstIndex(where: {$0.name == cityName}) {
            return cities[index]
        }
        return nil
    }
    
    func moveCityWhenDisappear(name: String) {
        if let index = citiesInfo.firstIndex(where: {$0.cityName == name}) {
            citiesInfo[index].offsetY = AppViewModelConstants.cityStartCoordinate
            citiesInfo[index].offsetX = AppViewModelConstants.cityEndCoordinate
        }
    }
    
    func moveCityWhenAppear(name: String) {
        if let index = citiesInfo.firstIndex(where: {$0.cityName == name}) {
            citiesInfo[index].offsetX = AppViewModelConstants.cityEndCoordinate
            citiesInfo[index].offsetY = AppViewModelConstants.cityEndCoordinate
        }
    }
    
    func getOffsetOfCity(name: String) -> (x: CGFloat, y: CGFloat) {
        if let index = citiesInfo.firstIndex(where: {$0.cityName == name}) {
            return (citiesInfo[index].offsetX, citiesInfo[index].offsetY)
        }
        return (0,0)
    }
    
    //MARK: - Temperature
    
    func addDateToTemperature(value: Date) {
        appLogic.addDateToTemperature(value: value)
    }
    
    func addValueToTemperature(value: Int) {
        appLogic.addValueToTemperature(value: value)
    }
    
    func addWindToTemperature(value: Double) {
        appLogic.addWindToTemperature(value: value)
    }
    
    func addCloudsToTemperature(value: CloudStatus) {
        var cloudStatus = 0
        switch value {
        case .sun:
            cloudStatus = 800
        case .clouds:
            cloudStatus = 801
        case .rain:
            cloudStatus = 500
        case .storm:
            cloudStatus = 200
        case .snow:
            cloudStatus = 600
        case .mist:
            cloudStatus = 700
        }
        appLogic.addCloudsToTemperature(value: cloudStatus)
    }
    
    func addVisibilityToTemperature(value: Int) {
        appLogic.addVisibilityToTemperature(value: AppViewModelConstants.convertToMeters(value: value))
    }
    
    func addAdditionalDataToTemperature() {
        appLogic.addAdditionalDataToTemperature()
    }
    
    func addTemperature(name: String, date: Date) {
        appLogic.addTemperatureToCity(name: name, date: date)
        save()
    }
    
    func getAvgTotal(of city: City, in year: Int) -> String {
        return city.avgTempTotal(temperatureFormat: valueFormat, year: year)
    }
    
    func getAvgSeason(of city: City, in year: Int, in seasonType: SeasonType) -> String {
        return city.getAvgTemp(temperatureFormat: valueFormat, seasonType: seasonType, year: year)
    }
    
    func removeTemperature(cityName: String, indexSet: IndexSet) {
        appLogic.removeTemperatureFromCity(name: cityName, indexSet: indexSet)
        save()
    }
    
    
}

//MARK: - Constants

private struct AppViewModelConstants {
    
    static let userKey = "UserData"
    static let cityStartCoordinate: CGFloat = -1000
    static let cityEndCoordinate: CGFloat = 0
    static let seedLength = 20
    
    static func convertToMeters(value: Int) -> Int {
        return value * 1000
    }
    
}
