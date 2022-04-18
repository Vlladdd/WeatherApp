//
//  MainMenuView.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 22.03.2022.
//

import SwiftUI

//main view that represents 2 tabs: cities and their info and cities and temperatures redactor
struct MainMenuView: View {
    
    //MARK: - Properties
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    //stores name of last selected city, so when we navigating or switching tabs its not resets
    @State private var selectedCity = ""
    //gets name of the first city when view appears (only once)
    @State private var citySelected = false
    //local or server
    @State private var dataType = DataType.local
    
    //MARK: - Init
    
    init() {
        //removes or sets standard colors of form, list etc
        removeStandardColors()
    }
    
    //MARK: - Body
    
    var body: some View {
        mainBody
    }
    
    // both tabs
    @ViewBuilder
    private var mainBody: some View {
        if #available(iOS 15.0, *) {
            TabView {
                mainMenuTab
                settingsTab
            }
            .navigationViewStyle(StackNavigationViewStyle())
            //sets background of status bar
            .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
                Color.clear
                    .frame(height: 0)
                    .background(Color(UIColor.systemBackground).opacity(MainViewConstants.statusBarOpacity))
            }
        } else {
            TabView {
                mainMenuTab
                settingsTab
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    //MARK: - First Tab
    
    //cities tab
    @ViewBuilder
    private var mainMenuTab: some View {
        NavigationView {
            if appViewModel.cities.count > 0 {
                citiesLinks
            }
            else {
                Text("Add city")
                    .font(.largeTitle)
            }
        }
        .onAppear {
            if !citySelected {
                if appViewModel.cities.count > 0 {
                    selectedCity = appViewModel.cities.first!.name
                }
                appViewModel.getCitiesData()
                citySelected = true
            }
            else if selectedCity == "" && appViewModel.cities.count > 0 {
                selectedCity = appViewModel.cities.first!.name
            }
        }
        .tabItem {
            Label("Main Menu", systemImage: "list.dash")
        }
    }
    
    //gets data and then shows cities in tabView
    @ViewBuilder
    private var citiesLinks: some View {
        Group {
            if appViewModel.dataServerIsAvailable {
                GeometryReader { geometry in
                    citiesTabView(in: geometry.size, safeAreaTop: geometry.safeAreaInsets.top)
                }
            }
            else {
                Text("Server is not available")
            }
        }
        .toolbar {
            toolbarContent
        }
        .navigationTitle("Cities")
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            HStack {
                Button(action: {
                    appViewModel.getCitiesData()
                }, label: {
                    Text("Update")
                })
                Button(action: {
                    switch dataType {
                    case .local:
                        appViewModel.dataContext.update(strategy: LocalDataStrategy())
                    case .server:
                        appViewModel.dataContext.update(strategy: ServerDataStrategy())
                    }
                    dataType = dataType == .local ? .server : .local
                    appViewModel.getCitiesData()
                }, label: {
                    Text(dataType.rawValue.firstUppercased)
                })
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button(action: {
                //animation when deleting city
                withAnimation(MainViewConstants.defaultAnimation) {
                    appViewModel.moveCityWhenDisappear(name: selectedCity)
                }
                //we need to wait for tab to move before removing city or there will be no animation
                //this is not a proper way, because if user close app before animation has finished
                //city will not be deleted. Good workaround for that is working with copy of cities,
                //but i leave it like this for now.
                Timer.scheduledTimer(withTimeInterval: MainViewConstants.delayWhenDelete, repeats: false, block: {_ in
                    appViewModel.removeCity(name: selectedCity)
                })
            }, label: {
                Text("Delete")
            })
        }
    }
    
    @ViewBuilder
    private func citiesTabView(in size: CGSize, safeAreaTop: CGFloat) -> some View {
        GeometryReader { geometry in
            ScrollView (.horizontal) {
                TabView (selection: $selectedCity) {
                    cities(in: size, safeAreaTop: safeAreaTop)
                }
                .frame(
                    width: geometry.size.width ,
                    height: geometry.size.height
                )
                .tabViewStyle(.page)
            }
        }
        .ignoresSafeArea()
    }
    
    //city link with name and background
    @ViewBuilder
    private func cities(in size: CGSize, safeAreaTop: CGFloat) -> some View {
        ForEach(appViewModel.cities) { city in
            ZStack(alignment: .top) {
                if appViewModel.checkCityStatus(name: city.name) {
                    getCityLink(city: city, safeAreaTop: safeAreaTop, size: size)
                        .offset(x: 0, y: appViewModel.getOffsetOfCity(name: city.name).y)
                        //onChange will not work on current selectedCity
                        //P.S. I dont know why, but if i dont add #if appViewModel.checkCityStatus(name: selectedCity)#, even despite
                        //that i have this #if# in ZSTack, onAppear will move city before it appears and even #selectedCity == city.name#
                        //not fixes the problem
                        .onAppear(perform: {
                            if appViewModel.checkCityStatus(name: selectedCity) && city.name == selectedCity {
                                withAnimation(MainViewConstants.defaultAnimation) {
                                    appViewModel.moveCityWhenAppear(name: selectedCity)
                                }
                            }
                        })
                        //carousel animation
                        .onChange(of: selectedCity, perform: {newValue in
                            if newValue != city.name {
                                withAnimation(MainViewConstants.carouselAnimation) {
                                    appViewModel.moveCityWhenDisappear(name: city.name)
                                }
                            }
                            else {
                                withAnimation(MainViewConstants.carouselAnimation) {
                                    appViewModel.moveCityWhenAppear(name: city.name)
                                }
                            }
                        })
                }
                else {
                    ProgressView()
                        .padding()
                        .progressViewStyle(CircularProgressViewStyle(tint: MainViewConstants.rowColor))
                        .background(MainViewConstants.backgroundForRow.colorInvert())
                }
            }
        }
    }
    
    @ViewBuilder
    private func getCityLink(city: City, safeAreaTop: CGFloat, size: CGSize) -> some View {
        //getting current temperature data
        let data = city.temperatureData.sorted(by: {$0.date > $1.date})
        if data.count > 0 {
            getCloudStatus(temperatureData: data.first!)
            //when change device orientation some backgrounds are not loading;
            //this fixes the problem
                .id(city.name)
        }
        else {
            makeTextBackground(text: "No Cloud Data")
        }
        VStack {
            if data.count > 0 {
                HStack {
                    Text(data.first!.date.toStringDateHM)
                        .padding([.leading,.trailing])
                        .background(MainViewConstants.backgroundForRow)
                    Spacer()
                }
                .padding()
            }
            Spacer()
            NavigationLink(destination: {
                CityDataView(city: city)
            }) {
                Text(city.name)
                    .frame(maxWidth: .infinity)
            }
            .disabled(appViewModel.getOffsetOfCity(name: city.name).y == 0 ? false : true)
            .tag(city.name)
            .frame(maxWidth: .infinity)
            .background(MainViewConstants.backgroundForRow)
            .padding([.leading,.trailing], MainViewConstants.paddingForTitle)
            .font(.largeTitle)
            Spacer()
        }
        .offset(x: 0, y: safeAreaTop)
        .frame(height: size.height)
    }
    
    //gets background of city depending on current clouds status code
    @ViewBuilder
    private func getCloudStatus(temperatureData: Temperature) -> some View {
        if let value = temperatureData.additionalData?.weather?.first?.id{
            switch value {
            case _ where value == 800:
                makeAnimatedBackground(imageName: "GIFs/sun.gif")
            case _ where value >= 801 && value < 810:
                makeAnimatedBackground(imageName: "GIFs/clouds.gif")
            case _ where value >= 500 && value < 600:
                makeAnimatedBackground(imageName: "GIFs/rain.gif")
            case _ where value >= 200 && value < 300:
                makeAnimatedBackground(imageName: "GIFs/storm.gif")
            case _ where value >= 600 && value < 700:
                makeAnimatedBackground(imageName: "GIFs/snow.gif")
            case _ where value >= 700 && value < 800:
                makeAnimatedBackground(imageName: "GIFs/mist.gif")
            default:
                makeTextBackground(text: "Code: \(String(value))")
            }
        }
        else {
            makeTextBackground(text: "No Cloud Data")
        }
    }
    
    //MARK: - Second Tab

    @ViewBuilder
    private var settingsTab: some View {
        NavigationView {
            ZStack {
                makeBackground(image: UIImage(named: "Editor")!)
                VStack {
                    navLinks
                }
                .font(.largeTitle)
                .lineLimit(nil)
                .padding([.leading,.trailing], MainViewConstants.paddingForTitle)
                .navigationTitle("Edit")
            }
            .ignoresSafeArea()
        }
        .tabItem {
            Label("Settings", systemImage: "gear").background(MainViewConstants.rowColor)
        }
    }
    
    //links to editors
    @ViewBuilder
    private var navLinks: some View {
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        Group {
            editCityNavLink
            editTemperatureNavLink
        }
        .padding()
        .background(MainViewConstants.backgroundForRow)
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    //link to city editor
    @ViewBuilder
    private var editCityNavLink: some View {
        NavigationLink(destination: {
            CityEditor(cityName: selectedCity)
        }) {
            Text("Add/Edit City")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    //link to temperature editor
    @ViewBuilder
    private var editTemperatureNavLink: some View {
        NavigationLink(destination: {
            TemperatureEditor(cityName: selectedCity)
        }) {
            Text("Add/Edit Temperature")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
}

//MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView().environmentObject(AppViewModel())
    }
}

//MARK: - Constants

private struct MainViewConstants {
    static let rowColor = Color(UIColor.systemBackground)
    static let navigationOpacity = 0.7
    static let statusBarOpacity = 0.5
    static let cornerRadius: Double = 20
    static let paddingForTitle: Double = 50
    static let delayWhenDelete = 0.2
    static let durationOfCarouselAnimation = 0.2
    static let carouselAnimation = Animation.easeInOut(duration: durationOfCarouselAnimation)
    static let defaultAnimation = Animation.easeInOut
    
    @ViewBuilder
    static var backgroundForRow: some View {
        RoundedRectangle(cornerRadius: cornerRadius) .foregroundColor(rowColor).opacity(navigationOpacity)
    }
}
