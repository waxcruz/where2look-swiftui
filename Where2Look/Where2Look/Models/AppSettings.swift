//
//  AppSettings.swift
//  Where2Look
//
//  Created by Bill Weatherwax on 4/12/26.
//


import Foundation
import Combine

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var soundVolume: Float = 0.2
}
