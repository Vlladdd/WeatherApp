//
//  CityView.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 23.03.2022.
//

import SwiftUI

//view that represents city data
struct CityDataView: View {
    
    //MARK: - Properties
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    let city: City
    
    @State private var valueStyle = ValueStyle.metric
    @State private var editMode: EditMode = .inactive
    //used to animate list when he is changed
    @State private var listId = 0
    @State private var year = Date().get(.year)
    @State private var month = Date().get(.month)
    
    private let months: [Int: Month] = [1: .january, 2: .february, 3: .march, 4: .april, 5: .may, 6: .june, 7: .jule, 8: .august, 9: .september, 10: .october, 11: .november, 12: .december]
    
    //MARK: - Body
    
    var body: some View {
        mainBody
    }
    
    //MARK: - List
    
    //list with links to year or day data
    @ViewBuilder
    private var mainBody: some View {
        // used container here to not animate background
        ZStack {
            VStack {
                HStack {
                    yearPicker
                    monthPicker
                }
                .frame(maxHeight: 0)
                .padding()
                List {
                    Group {
                        yearsData
                        daysData
                    }
                    .foregroundColor(CityDataViewConstants.textColor)
                    .listRowBackground(CityDataViewConstants.backgroundForRow)
                }
            }
            .id(listId)
            .transition(.identity)
            .delayedAnimation(delay: CityDataViewConstants.waitBeforeAnimate, animation: CityDataViewConstants.animation)
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $editMode)
            .navigationTitle(city.name)
        }
        .background(
            background
        )
    }
    
    @ViewBuilder
    private var yearPicker: some View {
        //using menu here to make proper background
        //background is not working in picker
        Menu {
            Picker(selection: $year) {
                ForEach(city.years.sorted(by: >), id: \.self) {year in
                    Text(String(year)).tag(year)
                }
            } label: {}
        } label: {
            ZStack {
                CityDataViewConstants.backgroundForRow
                Text(String(year))
                    .font(.title2)
            }
        }
    }
    
    @ViewBuilder
    private var monthPicker: some View {
        Menu {
            Picker(selection: $month) {
                ForEach(months.sorted(by: {$0.key > $1.key}), id: \.key) {key, month in
                    Text(month.rawValue).tag(key)
                }
            } label: {}
        } label: {
            ZStack {
                CityDataViewConstants.backgroundForRow
                Text(String(month))
                    .font(.title2)
            }
        }
    }
    
    //if coordinates of city exists makes map as background;
    //otherwise makes city image as background
    @ViewBuilder
    private var background: some View {
        let temperatureData = city.temperatureData.sorted(by: {$0.date > $1.date})
        if temperatureData.count > 0 {
            if let lat = temperatureData.first!.additionalData?.coord?.lat, let lon = temperatureData[0].additionalData?.coord?.lon {
                makeMapBackground(lat: lat, lon: lon)
            }
            else {
                makeBackground(image: appViewModel.getCityImage(cityName: city.name))
            }
        }
        else {
            makeBackground(image: appViewModel.getCityImage(cityName: city.name))
        }
    }
    
    //MARK: Links of list
    
    //links to year data
    @ViewBuilder
    private var yearsData: some View {
        ForEach(city.years.sorted(by: >), id: \.self) {year in
            if self.year == year {
                NavigationLink(String(year), destination: {
                    CityYearView(city: city, year: year, valueStyle: $valueStyle)
                })
            }
        }
    }
    
    //links to day data
    @ViewBuilder
    private var daysData: some View {
        ForEach(city.dates.sorted(by: >), id: \.self) {date in
            if date.get(.year) == year && date.get(.month) == month{
                if let time = city.getAllTimes(in: city.getAllData(from: date)).sorted(by: >).first {
                    NavigationLink(date.toString, destination: {
                        CityDayView(city: city, temperatureData: city.getAllData(from: date), time: time, valueStyle: $valueStyle)
                    })
                }
            }
        }
        .onDelete(){indexSet in
            withAnimation {
                appViewModel.removeTemperature(cityName: city.name, indexSet: indexSet)
                listId += 1
            }
        }
    }
}

//MARK: - Previews

struct CityView_Previews: PreviewProvider {
    static var previews: some View {
        CityDataView(city: City(name: "Kyiv", id: "Kyiv", type: .small, temperatureData: Temperature.getRandomTemperatureData())).environmentObject(AppViewModel())
    }
}

//MARK: - Constants

private struct CityDataViewConstants {
    
    static let textColor = Color(UIColor.systemBackground.inverseColor())
    static let rowColor = Color(UIColor.systemBackground)
    static let navigationOpacity = 0.7
    static let cornerRadius: Double = 20
    static let waitBeforeAnimate = 0.1
    static let animation = Animation.easeInOut
    
    @ViewBuilder
    static var backgroundForRow: some View {
        RoundedRectangle(cornerRadius: cornerRadius) .foregroundColor(rowColor).opacity(navigationOpacity)
    }
}
