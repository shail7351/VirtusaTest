//
//  WeatherInfoViewModel.swift
//  VirtusaTest
//
//  Created by Shailesh Gole on 05/05/23.
//

import Foundation
import CoreLocation

protocol UpdateWeatherProtocol {
  func updateCityWeather()
}

class WeatherInfoViewModel {

  var weatherInfo: WeatherInfo?
  var locationHandler = LocationManager()
  var updateWeatherDelegate: UpdateWeatherProtocol?
  
  func checkForSavedCity() {
    if let savedCity = UserDefaultUtility().getCity() {
      getWeatherData(forCity: savedCity)
    } else {
      initializeLocationHandler()
    }
  }
  
  private func initializeLocationHandler() {
    locationHandler.currentLocationDelegate = self
    locationHandler.askForPermission()
  }
  
  func getCityname(currentLocation: (Double, Double)) {
    let cityEndpoint = "geo/1.0/reverse?lat=\(currentLocation.0)&lon=\(currentLocation.1)"
    NetworkManager.shared.getCityNameInfo(urlEndPoints: cityEndpoint) { [weak self] cityData in
      if let self = self, let city = cityData.first?.name {
        self.getWeatherData(forCity: city)
      }
    }
  }
    
  func getWeatherData(forCity: String) {
    NetworkManager.shared.getCityWeatherInfo(cityName: forCity) { [weak self] weatherData in
      DispatchQueue.main.async {
        UserDefaultUtility().saveCity(cityName: forCity)
        self?.weatherInfo = weatherData
        self?.updateWeatherDelegate?.updateCityWeather()
      }
    }
  }
  
  func getIconImageForWeather(iconName: String, completion: @escaping (Data?) -> Void) {
    let iconImageEndpoint = "https://openweathermap.org/img/wn/\(iconName)@2x.png"
    DispatchQueue.global().async {
      guard let url = URL(string: iconImageEndpoint) else {
        return
      }
      let data = try? Data(contentsOf: url)
      DispatchQueue.main.async {
        completion(data)
      }
    }
  }
}

extension WeatherInfoViewModel: CurrentLocationProtocol {
  func didReceivedCurrentLocation(currentLocation: (Double, Double)) {
    getCityname(currentLocation: currentLocation)
  }
}
