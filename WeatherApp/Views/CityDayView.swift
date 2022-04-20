//
//  CityDayView.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 28.03.2022.
//

import SwiftUI
import SDWebImageSwiftUI

//view that represents city data by picked day
struct CityDayView: View {
    
    //MARK: - Properties
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    let city: City
    let temperatureData: [Temperature]
    
    @State var time = "Pick time"
    //data for current picked time
    @State var temperatureDataInTime: Temperature?
    
    //for animation when values in form are changing
    @State private var offsetX: CGFloat = 0
    //disables ability to change valueStyle while avgTemperature is being displayed
    @State private var disabled = false
    @State var cloudsImage: UIImage?
    
    @Binding var valueStyle: ValueStyle
    
    //MARK: - Body
    
    var body: some View {
        mainBody
    }
    
    @ViewBuilder
    private var mainBody: some View {
        dataTable()
            .toolbar(content: {
                toolbarContent
            })
            .navigationTitle(city.name + " " + temperatureData.first!.date.toString)
            .onAppear {
                temperatureDataInTime = city.getData(from: temperatureData.first!.date, and: time)
            }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem {
            Picker("Pick value style", selection: $valueStyle, content: {
                Text("Metric").tag(ValueStyle.metric)
                Text("Standard").tag(ValueStyle.standard)
                Text("Imperial").tag(ValueStyle.imperial)
            })
                .disabled(disabled)
                .pickerStyle(.menu)
                .onChange(of: valueStyle, perform: {newValueStyle in
                    disabled = true
                    withAnimation(CityDayViewConstants.defaultAnimation) {
                        switch newValueStyle {
                        case .metric:
                            appViewModel.valueFormat.update(strategy: MetricStrategy())
                        case .standard:
                            appViewModel.valueFormat.update(strategy: StandardStrategy())
                        case .imperial:
                            appViewModel.valueFormat.update(strategy: ImperialStrategy())
                        }
                        offsetX = CityDayViewConstants.offsetXForAnimationWhenValuesChanged
                    }
                    Timer.scheduledTimer(withTimeInterval: CityDayViewConstants.durationForDefaultAnimation, repeats: false, block: {_ in
                        withAnimation(CityDayViewConstants.defaultAnimation) {
                            offsetX = 0
                        }
                    })
                    Timer.scheduledTimer(withTimeInterval: CityDayViewConstants.delayForDisabled, repeats: false, block: {_ in
                        disabled = false
                    })
                })
        }
    }
    
    //MARK: - Form
    
    //form with all data
    @ViewBuilder
    private func dataTable() -> some View {
        Form {
            timePickerSection
            //previously, there was no elses and this was working fine in simulator (iOS 15), but on real device (iOS 14) that was forcing an error,
            //if there are no value, that the nubmer of sections in Form was changed
            if let temperatureDataInTime = temperatureDataInTime {
                getSection(name: "Temperature", value: appViewModel.valueFormat.getTemperatureData(value: temperatureDataInTime.value))
                if let _ = temperatureDataInTime.additionalData?.weather?.first?.icon {
                    getWeatherSection
                }
                else {
                    getSection(name: "Weather", value: "No value")
                }
                if let value = temperatureDataInTime.additionalData?.weather?.first?.id, let cloudStatus = appViewModel.getCloudStatus(from: value) {
                    getSection(name: "Clouds", value: cloudStatus.rawValue.firstUppercased)
                }
                else {
                    getSection(name: "Clouds", value: "No value")
                }
                if let visibility = temperatureDataInTime.additionalData?.visibility {
                    getSection(name: "Visibility", value: appViewModel.valueFormat.getLengthData(value: visibility))
                }
                else {
                    getSection(name: "Visibility", value: "No value")
                }
                if let windSpeed = temperatureDataInTime.additionalData?.wind?.speed {
                    getSection(name: "Wind Speed", value: appViewModel.valueFormat.getSpeedData(value: windSpeed))
                }
                else {
                    getSection(name: "Wind Speed", value: "No value")
                }
                if let lat = temperatureDataInTime.additionalData?.coord?.lat, let lon = temperatureDataInTime.additionalData?.coord?.lon {
                    getSection(name: "Coordinates", value: "Longtitude: \(lon)\nLatitude: \(lat)")
                }
                else {
                    getSection(name: "Coordinates", value: "No value")
                }
            }
        }
        .background(getTemperatureStatus)
    }
    
    //gets background of form depending on temperature
    @ViewBuilder
    private var getTemperatureStatus: some View {
        if let temperatureDataInTime = temperatureDataInTime {
            let value = temperatureDataInTime.value
            switch value {
            case _ where value < CityDayViewConstants.normalTemperatureMinValue:
                makeAnimatedBackground(imageName: "GIFs/cold.gif")
            case _ where value >= CityDayViewConstants.normalTemperatureMinValue && value <= CityDayViewConstants.normalTemperatureMaxValue:
                makeAnimatedBackground(imageName: "GIFs/normal.gif")
            case _ where value > CityDayViewConstants.normalTemperatureMaxValue:
                makeAnimatedBackground(imageName: "GIFs/warm.gif")
            default:
                Text("No Temperature Data")
            }
        }
        else {
            makeBackground(image: appViewModel.getCityImage(cityName: city.name))
        }
    }
    
    //MARK: - Sections of form
    
    @ViewBuilder
    private var timePickerSection: some View {
        Section (content: {
            if let date = temperatureData.first?.date.toString, let allTimes = city.getAllTimes(from: date) {
                Menu {
                    Picker(selection: $time) {
                        Text("Average").tag("Average")
                        ForEach(allTimes, id: \.self) {time in
                            Text(time).tag(time)
                        }
                    } label: {}
                } label: {
                    ZStack {
                        CityDayViewConstants.backgroundForRow
                        Text(time)
                            .font(.title2)
                    }
                }
                .disabled(disabled)
            }
        }, header: {
            ZStack {
                CityDayViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text("Time")
                    .foregroundColor(CityDayViewConstants.textHeaderColor)
            }
            .padding()
        })
            .font(.title2)
            .listRowBackground(Color.clear)
            .onChange(of: time, perform: {newTime in
                disabled = true
                cloudsImage = nil
                withAnimation(CityDayViewConstants.defaultAnimation) {
                    if time != "Average" {
                        temperatureDataInTime = city.getData(from: temperatureData.first!.date, and: newTime)
                    }
                    else {
                        temperatureDataInTime = city.getAvgTempDataForDay(date: temperatureData.first!.date.toString)
                    }
                    //In iOS 15 we use AsyncImage so we dont need to process image in viewModel
                    if #available(iOS 15.0, *) {
                        
                    }
                    else {
                        if let weatherStatus = temperatureDataInTime?.additionalData?.weather?.first?.icon {
                            appViewModel.getCloudsImage(from: weatherStatus) {value in
                                cloudsImage = value
                            }
                        }
                    }
                    offsetX = CityDayViewConstants.offsetXForAnimationWhenValuesChanged
                }
                Timer.scheduledTimer(withTimeInterval: CityDayViewConstants.durationForDefaultAnimation, repeats: false, block: {_ in
                    withAnimation(CityDayViewConstants.defaultAnimation) {
                        offsetX = 0
                    }
                })
                Timer.scheduledTimer(withTimeInterval: CityDayViewConstants.delayForDisabled, repeats: false, block: {_ in
                    disabled = false
                })
            })
    }
    
    @ViewBuilder
    private func getSection(name: String, value: String) -> some View{
        Section (content: {
            ZStack {
                CityDayViewConstants.backgroundForRow.frame(maxWidth: CityDayViewConstants.maxWidthOfSectionContent)
                Text(value)
                    .foregroundColor(CityDayViewConstants.textColor)
                    .animation(CityDayViewConstants.defaultAnimation)
            }
            .offset(x: offsetX, y: 0)
        }, header: {
            ZStack {
                CityDayViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text(name)
                    .foregroundColor(CityDayViewConstants.textHeaderColor)
            }
            .padding()
        })
            .font(.title2)
            .listRowBackground(Color.clear)
    }
    
    //gets weather icon
    @ViewBuilder
    private var getWeatherSection: some View {
        Section (content: {
            if let weatherStatus = temperatureDataInTime!.additionalData?.weather?[0].icon {
                if #available(iOS 15.0, *) {
                    ZStack {
                        CityDayViewConstants.backgroundForRow.frame(maxWidth: CityDayViewConstants.maxWidthOfSectionContent)
                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weatherStatus)@2x.png")!, content: {image in
                            image
                                .background(CityDayViewConstants.backgroundForWeather)
                                .animation(CityDayViewConstants.defaultAnimation)
                        }, placeholder: {
                            ProgressView()
                                .padding()
                                .progressViewStyle(CircularProgressViewStyle(tint: CityDayViewConstants.rowColor))
                                .background(CityDayViewConstants.backgroundForWeather)
                        })
                    }
                    .offset(x: offsetX, y: 0)
                } else {
                    ZStack {
                        CityDayViewConstants.backgroundForRow.frame(maxWidth: CityDayViewConstants.maxWidthOfSectionContent)
                        if let cloudsImage = cloudsImage {
                            Image(uiImage: cloudsImage)
                                .background(CityDayViewConstants.backgroundForWeather)
                                .animation(CityDayViewConstants.defaultAnimation)
                        }
                        else {
                            ProgressView()
                                .padding()
                                .progressViewStyle(CircularProgressViewStyle(tint: CityDayViewConstants.rowColor))
                                .background(CityDayViewConstants.backgroundForWeather)
                        }
                    }
                    .onAppear(perform: {
                        appViewModel.getCloudsImage(from: weatherStatus){value in
                            cloudsImage = value
                        }
                    })
                    .offset(x: offsetX, y: 0)
                }
            }
        }, header: {
            ZStack {
                CityDayViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text("Weather")
                    .foregroundColor(CityDayViewConstants.textHeaderColor)
            }
            .padding()
        })
            .font(.title2)
            .listRowBackground(Color.clear)
    }
}

//MARK: - Previews

struct CityDayView_Previews: PreviewProvider {
    static var previews: some View {
        CityDayView(city: City(name: "Kyiv", id: "Kyiv", type: .small, temperatureData: Temperature.getRandomTemperatureData()), temperatureData: Temperature.getRandomTemperatureData(), valueStyle: .constant(.metric)).environmentObject(AppViewModel())
    }
}

//MARK: - Constants

private struct CityDayViewConstants {
    static let rowColor = Color(UIColor.systemBackground.inverseColor())
    static let headerColor = Color(UIColor.systemBackground)
    static let weatherColor = Color.red
    static let rowOpacity = 0.7
    static let headerOpacity = 0.7
    static let textColor = Color(UIColor.systemBackground)
    static let textHeaderColor = Color(UIColor.systemBackground.inverseColor())
    static let cornerRadius: Double = 20
    static let maxWidthOfSectionContent: Double = .infinity
    static let delayForDisabled = 1.0
    static let durationForDefaultAnimation = 0.5
    static let offsetXForAnimationWhenValuesChanged: CGFloat = 30
    static let normalTemperatureMinValue = 5
    static let normalTemperatureMaxValue = 20
    static let defaultAnimation = Animation.easeInOut(duration: durationForDefaultAnimation)
    
    @ViewBuilder
    static var backgroundForRow: some View {
        RoundedRectangle(cornerRadius: cornerRadius) .foregroundColor(rowColor).opacity(rowOpacity)
    }
    @ViewBuilder
    static var headerBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(headerColor).opacity(headerOpacity)
    }
    
    @ViewBuilder
    static var backgroundForWeather: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(weatherColor).opacity(headerOpacity)
    }
}
