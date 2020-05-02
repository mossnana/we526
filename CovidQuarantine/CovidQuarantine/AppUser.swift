//
//  AppUser.swift
//  CovidQuarantine
//
//  Created by Student07 on 2/5/2563 BE.
//  Copyright © 2563 MO IO. All rights reserved.
//

import Foundation

class AppUser {
    let name: String
    let id: String
    let latitude: String
    let longtitude: String
    init(name: String, id: String, latitude: String, longtitude: String) {
        self.name = name
        self.id = id
        self.latitude = latitude
        self.longtitude = longtitude
    }
}
