//
//  TemperatureDataStrategy.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 26.03.2022.
//

import Foundation

//MARK: - Data Strategy

class DataContext {

    private var strategy: DataStrategy

    init(strategy: DataStrategy) {
        self.strategy = strategy
    }

    func update(strategy: DataStrategy) {
        self.strategy = strategy
    }

    func getData(cityName: String, completion: @escaping (([Temperature], Error?) -> Void)) {
        
        print("Getting data")
        
        strategy.getData(cityName: cityName, completion: completion)
    }
    
}

//interface for data strategy
protocol DataStrategy {
    
    func getData(cityName: String, completion: @escaping (([Temperature], Error?) -> Void)) -> Void
}

//MARK: - Local Data Strategy

class LocalDataStrategy: DataStrategy {
    
    static private let userKey = "UserData"
    
    func getData(cityName: String, completion: @escaping (([Temperature], Error?) -> Void)) {
        var cities = [City]()
        var result = [Temperature]()
        if let jsonData = UserDefaults.standard.data(forKey: LocalDataStrategy.userKey), let data = try? JSONDecoder().decode(AppLogic.self, from: jsonData){
            cities = data.cities
        }
        for city in cities {
            if city.name == cityName {
                result = city.temperatureData
            }
        }
        completion(result, nil)
    }
}

//MARK: - Server Data Strategy

class ServerDataStrategy: DataStrategy {
    
    //first gets coordinates of city by name then gets data by given coordinates
    func getData(cityName: String, completion: @escaping (([Temperature], Error?) -> Void)) {
        let temperatureBuilder = ConcreteTemperatureBuilder()
        var result = [Temperature]()
        var geographyError: Error?
        let temperatureURL = getTemperatureUrl(of: cityName.replacingOccurrences(of: " ", with: "")){error in
            if let error = error {
                geographyError = error
            }
        }
        if let geographyError = geographyError {
            completion(result, geographyError)
        }
        else {
            if let temperatureURL = temperatureURL {
                let task = URLSession.shared.dataTask(with: temperatureURL, completionHandler: { data, response, error in
                    if error == nil {
                        if let data = data {
                            if let tempData = try? JSONDecoder().decode(AdditionalData.self, from: data){
                                if let dt = tempData.dt {
                                    temperatureBuilder.produceDate(value: Date(timeIntervalSince1970: TimeInterval(dt)))
                                }
                                if let temp = tempData.main?.temp {
                                    temperatureBuilder.produceValue(value: Int(temp))
                                }
                                temperatureBuilder.produceAdditionalData(value: tempData)
                            }
                            result.append(temperatureBuilder.retrieveProduct())
                            completion(result, nil)
                        }
                    }
                    else {
                        print(error!.localizedDescription)
                        completion(result, error)
                    }
                })
                task.resume()
            }
            else {
                completion(result, LoadError.somethingWentWrong)
            }
        }
    }
    
    private func getTemperatureUrl(of cityName: String, completion: @escaping ((Error?) -> Void)) -> URL?{
        // we have to use DispatchGroup here, because we cant look for data, before we get coordinates of city
        let group = DispatchGroup()
        var lat: Double = 0
        var lon: Double = 0
        let geographyURL = URL(string: "https://api.openweathermap.org/geo/1.0/direct?q=\(cityName)&limit=1&appid=5ed46351fb7959ac01daa09483af13ed")
        if let geographyURL = geographyURL {
            group.enter()
            let task = URLSession.shared.dataTask(with: geographyURL, completionHandler: { data, response, error in
                if error == nil {
                    if let data = data {
                        if let jsonData = try? JSONSerialization.jsonObject(with: data) {
                            if let cities = jsonData as? [[String: Any]] {
                                if cities.count > 0 {
                                    if let cityLat = cities.first!["lat"] as? Double, let cityLon = cities.first!["lon"] as? Double {
                                        lat = cityLat
                                        lon = cityLon
                                    }
                                }
                            }
                        }
                    }
                    group.leave()
                }
                else {
                    print(error!.localizedDescription)
                    completion(error)
                    group.leave()
                }
            })
            task.resume()
            group.wait()
        }
        if lat != 0 && lon != 0 {
            let temperatureURL = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=5ed46351fb7959ac01daa09483af13ed&units=metric")
            return temperatureURL
        }
        else {
            return nil
        }
    }
    
}

