//
//  CityEditor.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 23.03.2022.
//

import SwiftUI

//view that represents city editor
struct CityEditor: View {
    
    //MARK: - Properties
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    //name of picked existed city
    @State var cityName: String
    
    //create new city or change data of existed city
    @State private var createNewCity = true
    @State private var newCityName = ""
    @State private var cityType = CityType.small
    
    //MARK: - Body
    
    var body: some View {
        ZStack {
            makeBackground(image: UIImage(named: "CityEditor")!)
            mainBody
        }
    }
    
    @ViewBuilder
    private var mainBody: some View {
        Group {
            editCityForm
        }
        .navigationTitle("Add/Edit City")
        .padding()
    }
    
    //MARK: - Form
    
    @ViewBuilder
    private var editCityForm: some View {
        Form {
            Group {
                cityNameSection
                cityTypeSection
                readySection
            }
            .font(.title2)
            .listRowBackground(Color.clear)
        }
        .background(CityEditorViewConstants.formBackground)
    }
    
    //MARK: - Sections of form
    
    //create new city or edit existed
    @ViewBuilder
    private var cityNameSection: some View {
        Section(content: {
            cityNameType
            if createNewCity {
                createCity
            }
            else {
                editCity
            }
        }, header: {
            ZStack {
                CityEditorViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text("City Name")
                    .foregroundColor(CityEditorViewConstants.textHeaderColor)
            }
            .padding()
        })
            .onChange(of: cityName, perform: {newValue in
                cityType = appViewModel.getCity(cityName: newValue)?.type ?? .small
            })
            .onChange(of: createNewCity, perform: {_ in
                cityType = appViewModel.getCity(cityName: cityName)?.type ?? .small
            })
    }
    
    //changes createNewCity variable
    @ViewBuilder
    private var cityNameType: some View {
        Menu {
            Picker(selection: $createNewCity) {
                Text("New City")
                    .tag(true)
                Text("Pick City")
                    .tag(false)
            } label: {}
        } label: {
            ZStack {
                CityEditorViewConstants.backgroundForRow.frame(maxWidth: CityEditorViewConstants.maxWidthOfSectionContent)
                Text(createNewCity == true ? "New City" : "Pick City")
                    .font(.title2)
            }
        }
    }
    
    //makes textfield to enter new city name
    @ViewBuilder
    private var createCity: some View {
        ZStack (alignment: .leading){
            CityEditorViewConstants.backgroundForRow.frame(maxWidth: CityEditorViewConstants.maxWidthOfSectionContent)
            TextField("Enter City Name", text: $newCityName)
                .padding(.leading, CityEditorViewConstants.textFieldLeading)
                .onChange(of: newCityName, perform: {newValue in
                    cityName = newValue
                })
                .foregroundColor(CityEditorViewConstants.textColor)
                .placeholder(when: newCityName.isEmpty) {
                    Text("Enter City Name")
                        .padding(.leading, CityEditorViewConstants.textFieldLeading)
                        .foregroundColor(CityEditorViewConstants.textColor)
                }
        }
    }
    
    //makes Picker with existed cities
    @ViewBuilder
    private var editCity: some View {
        Menu {
            Picker(selection: $cityName) {
                ForEach(appViewModel.cities, id: \.name){city in
                    Text(city.name)
                        .tag(city.name)
                }
            }
            label: {}
        } label: {
            ZStack {
                CityEditorViewConstants.backgroundForRow.frame(maxWidth: CityEditorViewConstants.maxWidthOfSectionContent)
                Text(cityName)
                    .font(.title2)
            }
        }
    }
    
    @ViewBuilder
    private var cityTypeSection: some View {
        Section(content: {
            Menu {
                Picker(selection: $cityType) {
                    Text("Small")
                        .tag(CityType.small)
                    Text("Medium")
                        .tag(CityType.medium)
                    Text("Big")
                        .tag(CityType.big)
                } label: {}
            } label: {
                ZStack {
                    CityEditorViewConstants.backgroundForRow.frame(maxWidth: CityEditorViewConstants.maxWidthOfSectionContent)
                    Text(cityType.rawValue.firstUppercased)
                        .font(.title2)
                }
            }
        }, header: {
            ZStack {
                CityEditorViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text("City Type")
                    .foregroundColor(CityEditorViewConstants.textHeaderColor)
            }
            .padding()
        })
    }
    
    //makes button to accept data
    @ViewBuilder
    private var readySection: some View {
        Section(content: {
            Button(action: {
                appViewModel.addCity(name: cityName, type: cityType)
            }, label: {
                ZStack {
                    CityEditorViewConstants.headerBackground.frame(maxWidth: .infinity)
                    Text("Ready")
                }
                .padding()
            })
                .buttonStyle(.borderless)
        })
    }
}

//MARK: - Previews

struct CityEditor_Previews: PreviewProvider {
    static var previews: some View {
        CityEditor(cityName: "").environmentObject(AppViewModel())
    }
}

//MARK: - Constants

private struct CityEditorViewConstants {
    static let rowColor = Color(UIColor.systemBackground.inverseColor())
    static let headerColor = Color(UIColor.systemBackground)
    static let textFieldLeading: Double = 10
    static let rowOpacity = 0.7
    static let headerOpacity = 0.7
    static let formColor = Color(UIColor.systemBackground)
    static let formOpacity = 0.35
    static let textColor = Color(UIColor.systemBackground)
    static let textHeaderColor = Color(UIColor.systemBackground.inverseColor())
    static let cornerRadius: Double = 20
    static let maxWidthOfSectionContent: Double = .infinity
    
    @ViewBuilder
    static var backgroundForRow: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(rowColor).opacity(rowOpacity)
    }
    @ViewBuilder
    static var headerBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(headerColor).opacity(headerOpacity)
    }
    @ViewBuilder
    static var formBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius).foregroundColor(formColor).opacity(formOpacity)
    }
}
