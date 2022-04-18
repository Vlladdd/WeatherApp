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
            .onAppear {
                showAvgTemp()
            }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .automatic, content: {
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
                        offsetX = CityYearViewConstants.offsetXForAnimationWhenValuesChanged
                    }
                    withAnimation(CityYearViewConstants.animationWhenValuesChanged) {
                        offsetX = 0
                        showAvgTemp()
                    }
                })
                .disabled(disabled)
        })
    }
    
    //displays averageTemperature then comebacks to all data
    private func showAvgTemp() {
        disabled = true
        withAnimation(CityYearViewConstants.animation) {
            showAvg = true
        }
        withAnimation(CityYearViewConstants.animationForAvg) {
            showAvg = false
        }
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
                    .animation(.easeInOut)
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
    static let animDur: Double = 2
    static let animDelay: Double = 1
    static let animation = Animation.linear(duration: animDur).delay(animDelay)
    static let rowColor = Color(UIColor.systemBackground.inverseColor())
    static let headerColor = Color(UIColor.systemBackground)
    static let rowOpacity = 0.7
    static let headerOpacity = 0.7
    static let textColor = Color(UIColor.systemBackground)
    static let textHeaderColor = Color(UIColor.systemBackground.inverseColor())
    static let cornerRadius: Double = 20
    static let maxWidthOfSectionContent: Double = .infinity
    static let delayForAnimationWhenValuesChanged = 0.2
    static let animationWhenValuesChanged = Animation.easeInOut.delay(delayForAnimationWhenValuesChanged)
    static let offsetXForAnimationWhenValuesChanged: CGFloat = 30
    static let animDurForAvg: Double = 2
    static let animDelayForAvg: Double = 4
    static let animationForAvg = Animation.easeInOut(duration: animDurForAvg).delay(animDelayForAvg)
    
    @ViewBuilder
    static var backgroundForRow: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(rowColor).opacity(rowOpacity)
    }
    
    @ViewBuilder
    static var headerBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(headerColor).opacity(headerOpacity)
    }
}
