//
//  WeatherAppApp.swift
//  WeatherApp
//
//  Created by Vlad Nechyporenko on 22.03.2022.
//

import SwiftUI

@main
struct WeatherApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView().environmentObject(AppViewModel())
        }
    }
}
