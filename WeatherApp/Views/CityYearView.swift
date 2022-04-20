//
//  CityYearView.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 28.03.2022.
//

import SwiftUI

//view that represents city data by picked year
struct CityYearView: View {
    
    //MARK: - Properties
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    let city: City
    let year: Int
    
    //for animation when values in form are changing
    @State private var offsetX: CGFloat = 0
    //disables ability to change valueStyle while avgTemperature is being displayed
    @State private var disabled = false
    //shows average temperature
    @State private var showAvg = false
    
    @Binding var valueStyle: ValueStyle
    
    //MARK: - Body
    
    var body: some View {
        mainBody
    }
    
    @ViewBuilder
    private var mainBody: some View {
        cityData
            .toolbar(content: {
                toolbarContent
            })
            .navigationTitle(city.name + " " + String(year))
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .automatic, content: {
            Picker("Pick value style", selection: $valueStyle, content: {
                Text("Metric").tag(ValueStyle.metric)
                Text("Standard").tag(ValueStyle.standard)
                Text("Imperial").tag(ValueStyle.imperial)
            })
                .pickerStyle(.menu)
                .onChange(of: valueStyle, perform: {newValueStyle in
                    //previously, i was trying to chain many animations with help of delay and this was working good
                    //in simulator (iOS 15), but unfortunately it was not working on my device (iOS 14), so i had
                    //to changed to this
                    disabled = true
                    withAnimation(CityYearViewConstants.defaultAnimation) {
                        switch newValueStyle {
                        case .metric:
                            appViewModel.valueFormat.update(strategy: MetricStrategy())
                        case .standard:
                            appViewModel.valueFormat.update(strategy: StandardStrategy())
                        case .imperial:
                            appViewModel.valueFormat.update(strategy: ImperialStrategy())
                        }
                        offsetX = CityYearViewConstants.offsetXForAnimationWhenValuesChanged
                    }
                    Timer.scheduledTimer(withTimeInterval: CityYearViewConstants.delayForDefaultAnimation, repeats: false, block: {_ in
                        withAnimation(CityYearViewConstants.defaultAnimation) {
                            offsetX = 0
                        }
                    })
                    Timer.scheduledTimer(withTimeInterval: CityYearViewConstants.delayForShowAvg, repeats: false, block: {_ in
                        showAvgTemp()
                    })
                })
                .disabled(disabled)
        })
    }
    
    //displays averageTemperature then comebacks to all data
    private func showAvgTemp() {
        withAnimation(CityYearViewConstants.animationForAvg) {
            showAvg = true
        }
        Timer.scheduledTimer(withTimeInterval: CityYearViewConstants.delayToHideAvg, repeats: false, block: {_ in
            withAnimation(CityYearViewConstants.animationForAvg) {
                showAvg = false
            }
        })
        Timer.scheduledTimer(withTimeInterval: CityYearViewConstants.delayForDisabled, repeats: false, block: {_ in
            disabled = false
        })
    }
    
    //reacts to publisher changess
    @ViewBuilder
    private var cityData: some View {
        if showAvg {
            avgTemp
        }
        else {
            allData
                .onAppear {
                    if !disabled {
                        disabled = true
                        Timer.scheduledTimer(withTimeInterval: CityYearViewConstants.delayForShowAvg, repeats: false, block: {_ in
                            showAvgTemp()
                        })
                    }
                }
        }
    }
    
    //MARK: - Average Temperature
    
    @ViewBuilder
    private var avgTemp: some View {
        ZStack {
            makeBackground(image: UIImage(named: "Seasons")!)
            Text("Average temperature:" + " " + appViewModel.getAvgTotal(of: city, in: year))
                .padding()
                .font(.title2)
                .foregroundColor(CityYearViewConstants.textColor)
                .background(CityYearViewConstants.backgroundForRow)
        }
    }
    
    //MARK: - Form
    
    @ViewBuilder
    private var allData: some View {
        Form {
            getSection(name: "City Type", value: city.type.rawValue)
            getSection(name: "Winter Season", value: appViewModel.getAvgSeason(of: city, in: year, in: .winter))
            getSection(name: "Spring Season", value: appViewModel.getAvgSeason(of: city, in: year, in: .spring))
            getSection(name: "Summer Season", value: appViewModel.getAvgSeason(of: city, in: year, in: .summer))
            getSection(name: "Autumn Season", value: appViewModel.getAvgSeason(of: city, in: year, in: .autumn))
        }
        .background(makeBackground(image: appViewModel.getCityImage(cityName: city.name)))
    }
    
    //MARK: - Sections of form
    
    @ViewBuilder
    private func getSection(name: String, value: String) -> some View{
        Section(content: {
            ZStack {
                CityYearViewConstants.backgroundForRow.frame(maxWidth: CityYearViewConstants.maxWidthOfSectionContent)
                Text(value)
                    .foregroundColor(CityYearViewConstants.textColor)
                    .animation(CityYearViewConstants.defaultAnimation)
            }
            .offset(x: offsetX, y: 0)
        }, header: {
            ZStack {
                CityYearViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text(name)
                    .foregroundColor(CityYearViewConstants.textHeaderColor)
            }
            .padding()
        })
            .font(.title2)
            .listRowBackground(Color.clear)
    }
    
}

//MARK: - Previews

struct CityYearView_Previews: PreviewProvider {
    static var previews: some View {
        CityYearView(city: City(name: "Kyiv", id: "Kyiv", type: .small, temperatureData: Temperature.getRandomTemperatureData()), year: 2022, valueStyle: .constant(.metric)).environmentObject(AppViewModel())
    }
}

//MARK: - Constants

private struct CityYearViewConstants {
    static let delayForDisabled: Double = 6
    static let rowColor = Color(UIColor.systemBackground.inverseColor())
    static let headerColor = Color(UIColor.systemBackground)
    static let rowOpacity = 0.7
    static let headerOpacity = 0.7
    static let textColor = Color(UIColor.systemBackground)
    static let textHeaderColor = Color(UIColor.systemBackground.inverseColor())
    static let cornerRadius: Double = 20
    static let maxWidthOfSectionContent: Double = .infinity
    static let offsetXForAnimationWhenValuesChanged: CGFloat = 30
    static let delayForShowAvg = 1.5
    static let delayForDefaultAnimation = 0.5
    static let durationForAvgAnimation = 2.0
    static let delayToHideAvg = 4.0
    static let defaultAnimation = Animation.easeInOut(duration: delayForDefaultAnimation)
    static let animationForAvg = Animation.easeInOut(duration: durationForAvgAnimation)
    
    @ViewBuilder
    static var backgroundForRow: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(rowColor).opacity(rowOpacity)
    }
    
    @ViewBuilder
    static var headerBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(headerColor).opacity(headerOpacity)
    }
}
