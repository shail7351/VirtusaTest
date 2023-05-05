//
//  UserDefaultUtility.swift
//  VirtusaTest
//
//  Created by Shailesh Gole on 05/05/23.
//

import Foundation

struct UserDefaultUtility {
  
  func saveCity(cityName: String) {
    UserDefaults.standard.set(cityName, forKey: "CityName")
  }
  
  func getCity() -> String? {
    if let savedCity = UserDefaults.standard.value(forKey: "CityName") as? String {
      return savedCity
    }
    return nil
  }
}
