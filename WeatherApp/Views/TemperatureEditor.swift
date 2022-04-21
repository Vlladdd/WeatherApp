//
//  TemperatureEditor.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 23.03.2022.
//

import SwiftUI

//view that represents temperature editor
struct TemperatureEditor: View {
    
    //MARK: - Properties
    
    @EnvironmentObject var appViewModel: AppViewModel
    
    //name of picked existed city
    @State var cityName = ""
    
    //enum CloudStatus
    @State private var cloudStatus: CloudStatus = .sun
    @State private var date = Date()
    @State private var temperatureValue = 0
    @State private var windValue: Double = 0
    @State private var visibilityValue = 0
    
    private let cloudStatuses: [CloudStatus] = [.clouds, .mist, .rain, .snow, .storm, .sun]
    
    //functions for stepper
    private func temperatureIncrement() {
        temperatureValue += TempEditorViewConstants.temperatureChanger
    }
    
    private func temperatureDecrement() {
        temperatureValue -= TempEditorViewConstants.temperatureChanger
    }
    
    private func windIncrement() {
        windValue += TempEditorViewConstants.windChanger
    }
    
    private func windDecrement() {
        windValue -= TempEditorViewConstants.windChanger
    }
    
    private func visibilityIncrement() {
        visibilityValue += TempEditorViewConstants.visibilityChanger
    }
    
    private func visibilityDecrement() {
        visibilityValue -= TempEditorViewConstants.visibilityChanger
    }
    
    //MARK: - Body
    
    var body: some View {
        ZStack {
            makeBackground(image: UIImage(named: "TemperatureEditor")!)
            mainBody
        }
    }
    
    @ViewBuilder
    private var mainBody: some View {
        temperatureEditorForm
            .background(TempEditorViewConstants.formBackground)
            .padding()
            .navigationTitle("Add/Edit Temperature")
    }
    
    //MARK: - Form
    
    @ViewBuilder
    private var temperatureEditorForm: some View {
        Form {
            Group {
                citySection
                cloudsSection
                dateSection
                makeValueSectionWithStepper(name: "Temperature value", value: "\(temperatureValue) ℃", onIncrement: temperatureIncrement, onDecrement: temperatureDecrement)
                makeValueSectionWithStepper(name: "Wind speed", value: "\(windValue.rounded(toPlaces: TempEditorViewConstants.digitsInDoubleAfterComa)) m/s", onIncrement: windIncrement, onDecrement: windDecrement)
                makeValueSectionWithStepper(name: "Visibility distance", value: "\(visibilityValue) km", onIncrement: visibilityIncrement, onDecrement: visibilityDecrement)
                readySection
            }
            .font(.title2)
            .listRowBackground(Color.clear)
        }
    }
    
    //MARK: - Sections of form
    
    //makes picker with existed cities
    @ViewBuilder
    private var citySection: some View {
        Section(content: {
            Menu {
                Picker(selection: $cityName) {
                    ForEach(appViewModel.cities){city in
                        Text(city.name.firstUppercased)
                            .tag(city.name)
                    }
                } label: {}
            } label: {
                ZStack {
                    TempEditorViewConstants.backgroundForRow.frame(maxWidth: TempEditorViewConstants.maxWidthOfSectionContent)
                    Text(cityName.firstUppercased)
                        .font(.title2)
                }
            }
        }, header: {
            ZStack {
                TempEditorViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text("City name")
                    .foregroundColor(TempEditorViewConstants.textHeaderColor)
            }
            .padding()
        })
    }
    
    //makes picker with existed cloud statuses
    @ViewBuilder
    private var cloudsSection: some View {
        Section(content: {
            Menu {
                Picker(selection: $cloudStatus) {
                    ForEach(cloudStatuses){cloudStatus in
                        Text(cloudStatus.rawValue.firstUppercased)
                            .tag(cloudStatus)
                    }
                } label: {}
            } label: {
                ZStack {
                    TempEditorViewConstants.backgroundForRow.frame(maxWidth: TempEditorViewConstants.maxWidthOfSectionContent)
                    Text(cloudStatus.rawValue.firstUppercased)
                        .font(.title2)
                }
            }
        }, header: {
            ZStack {
                TempEditorViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text("Cloud status")
                    .foregroundColor(TempEditorViewConstants.textHeaderColor)
            }
            .padding()
        })
    }
    
    //makes date picker
    @ViewBuilder
    private var dateSection: some View {
        Section(content: {
            // cant change colors of DataPicker ;/
            DatePicker("", selection: $date)
                .datePickerStyle(.compact)
        }, header: {
            ZStack {
                TempEditorViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text("Date and time")
                    .foregroundColor(TempEditorViewConstants.textHeaderColor)
            }
            .padding()
        })
    }
    
    //makes stepper
    @ViewBuilder
    private func makeValueSectionWithStepper (name: String, value: String, onIncrement: @escaping () -> Void, onDecrement: @escaping () -> Void) -> some View{
        Section(content: {
            ZStack {
                TempEditorViewConstants.backgroundForRow.frame(maxWidth: .infinity)
                Stepper {
                    Text(value)
                        .foregroundColor(TempEditorViewConstants.textColor)
                } onIncrement: {
                    onIncrement()
                } onDecrement: {
                    onDecrement()
                }
                .padding()
            }
            .frame(maxWidth: TempEditorViewConstants.maxWidthOfSectionContent)
        }, header: {
            ZStack {
                TempEditorViewConstants.headerBackground.frame(maxWidth: .infinity)
                Text(name)
                    .foregroundColor(TempEditorViewConstants.textHeaderColor)
            }
            .padding()
        })
    }
    
    //makes button to accept data
    @ViewBuilder
    private var readySection: some View {
        Section(content: {
            Button(action: {
                appViewModel.addValueToTemperature(value: temperatureValue)
                appViewModel.addDateToTemperature(value: date)
                appViewModel.addWindToTemperature(value: windValue)
                appViewModel.addVisibilityToTemperature(value: visibilityValue)
                appViewModel.addCloudsToTemperature(value: cloudStatus)
                appViewModel.addAdditionalDataToTemperature()
                appViewModel.addTemperature(name: cityName, date: date)
            }, label: {
                ZStack {
                    TempEditorViewConstants.headerBackground.frame(maxWidth: .infinity)
                    Text("Ready")
                }
                .padding()
            })
                .buttonStyle(.borderless)
        })
    }

}

//MARK: - Previews

struct TemperatureEditor_Previews: PreviewProvider {
    static var previews: some View {
        TemperatureEditor().environmentObject(AppViewModel())
    }
}

//MARK: - Constants

private struct TempEditorViewConstants {
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
    static let temperatureChanger = 1
    static let windChanger = 0.1
    static let visibilityChanger = 1
    static let digitsInDoubleAfterComa = 1
    
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
