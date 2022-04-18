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
                .onChange(of: valueStyle, perform: {newValueStyle in
                    withAnimation {
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
                    withAnimation(CityDayViewConstants.animationWhenValuesChanged) {
                        offsetX = 0
                    }
                })
        }
    }
    
    //MARK: - Form
    
    //form with all data
    @ViewBuilder
    private func dataTable() -> some View {
        Form {
            timePickerSection
            if let temperatureDataInTime = temperatureDataInTime {
                getSection(name: "Temperature", value: appViewModel.valueFormat.getTemperatureData(value: temperatureDataInTime.value))
                if let _ = temperatureDataInTime.additionalData?.weather?.first?.icon {
                    getWeatherSection
                }
                if let value = temperatureDataInTime.additionalData?.weather?.first?.id {
                    let cloudStatus = appViewModel.getCloudStatus(from: value)
                    if let cloudStatus = cloudStatus {
                        getSection(name: "Clouds", value: cloudStatus.rawValue.firstUppercased)
                    }
                }
                if let visibility = temperatureDataInTime.additionalData?.visibility {
                    getSection(name: "Visibility", value: appViewModel.valueFormat.getLengthData(value: visibility))
                }
                if let windSpeed = temperatureDataInTime.additionalData?.wind?.speed {
                    getSection(name: "Wind Speed", value: appViewModel.valueFormat.getSpeedData(value: windSpeed))
                }
                if let lat = temperatureDataInTime.additionalData?.coord?.lat, let lon = temperatureDataInTime.additionalData?.coord?.lon {
                    getSection(name: "Coordinates", value: "Longtitude: \(lon)\nLatitude: \(lat)")
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
            Menu {
                Picker(selection: $time) {
                    Text("Average").tag("Average")
                    ForEach(city.getAllTimes(in: temperatureData).sorted(), id: \.self) {time in
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
                withAnimation {
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
                            appViewModel.getCloudsImage(from: weatherStatus)
                        }
                    }
                    offsetX = CityDayViewConstants.offsetXForAnimationWhenValuesChanged
                }
                withAnimation(CityDayViewConstants.animationWhenValuesChanged) {
                    offsetX = 0
                }
            })
    }
    
    @ViewBuilder
    private func getSection(name: String, value: String) -> some View{
        Section (content: {
            ZStack {
                CityDayViewConstants.backgroundForRow.frame(maxWidth: CityDayViewConstants.maxWidthOfSectionContent)
                Text(value)
                    .foregroundColor(CityDayViewConstants.textColor)
                    .animation(.easeInOut)
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
                                .animation(.easeInOut)
                        }, placeholder: {
                            ProgressView()
                                .padding()
                                .progressViewStyle(CircularProgressViewStyle(tint: CityDayViewConstants.rowColor))
                                .background(CityDayViewConstants.backgroundForWeather)
                                .animation(.easeInOut)
                        })
                    }
                    .offset(x: offsetX, y: 0)
                } else {
                    ZStack {
                        CityDayViewConstants.backgroundForRow.frame(maxWidth: CityDayViewConstants.maxWidthOfSectionContent)
                        if let cloudsImage = appViewModel.cloudsImage {
                            Image(uiImage: cloudsImage)
                                .background(CityDayViewConstants.backgroundForWeather)
                                .animation(.easeInOut)
                        }
                        else {
                            ProgressView()
                                .padding()
                                .progressViewStyle(CircularProgressViewStyle(tint: CityDayViewConstants.rowColor))
                                .background(CityDayViewConstants.backgroundForWeather)
                                .animation(.easeInOut)
                        }
                    }
                    .offset(x: offsetX, y: 0)
                    .onAppear(perform: {
                        appViewModel.getCloudsImage(from: weatherStatus)
                    })
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
    static let delayForAnimationWhenValuesChanged = 0.2
    static let animationWhenValuesChanged = Animation.easeInOut.delay(delayForAnimationWhenValuesChanged)
    static let offsetXForAnimationWhenValuesChanged: CGFloat = 30
    static let normalTemperatureMinValue = 5
    static let normalTemperatureMaxValue = 20
    
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
