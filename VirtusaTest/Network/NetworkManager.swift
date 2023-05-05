//
//  NetworkManager.swift
//  VirtusaTest
//
//  Created by Shailesh Gole on 05/05/23.
//

import Foundation
import Combine

enum BaseURL: String {
  case weatherBaseURL = "https://api.openweathermap.org/"
  case cityBaseURL = "http://api.openweathermap.org/"
  case iconBaseURL = "https://openweathermap.org/"
}

enum EndPointUrl {
  case weather(cityName: String)
  case city(lat: String, lon: String)
  case icon(iconName: String)
  
  var endPoint: String {
    switch self {
    case .weather(let cityName):
      return BaseURL.weatherBaseURL.rawValue.appending("data/2.5/weather?q=\(cityName)")
    case .city(let lat,let lon):
      return BaseURL.cityBaseURL.rawValue.appending("geo/1.0/reverse?lat=\(lat)&lon=\(lon)")
    case .icon(let iconName):
      return BaseURL.iconBaseURL.rawValue.appending("img/wn/\(iconName)@2x.png")
    }
  }
}

class NetworkManager {
    
  static let shared = NetworkManager()
  
  private init() {}
  
  func getCityWeatherInfo(cityName: String, completion: @escaping (WeatherInfo) -> Void) {
    guard let url = URL(string: EndPointUrl.weather(cityName: cityName).endPoint.appending(("&appid=\(self.apiKey)"))) else {
      return
    }
    let urlRequest = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
      if error != nil {
        print("Error \(error.debugDescription)")
      } else if let data = data {
        do {
          let weatherData = try JSONDecoder().decode(WeatherInfo.self, from: data)
          completion(weatherData)
        } catch let error {
          print("Parse Error \(error)")
        }
      }
    }
    task.resume()
  }
  
  func getCityNameInfo(urlEndPoints: String, completion: @escaping ([CityInfoElement]) -> Void) {
    guard let url = URL(string: self.baseCityURL.appending(urlEndPoints).appending(("&appid=\(self.apiKey)"))) else {
      return
    }
    let urlRequest = URLRequest(url: url)
    let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
      if error != nil {
        print("Error \(error.debugDescription)")
      } else if let data = data {
        do {
          let cityData = try JSONDecoder().decode([CityInfoElement].self, from: data)
          completion(cityData)
        } catch let error {
          print("Parse Error \(error)")
        }
      }
    }
    task.resume()
  }
  
  private var cancellables = Set<AnyCancellable>()
  private let baseWeatherURL = "https://api.openweathermap.org/"
  private let baseCityURL = "http://api.openweathermap.org/"
  private let baseIconUrl = "https://openweathermap.org/"
  private let apiKey = "d9b91ef0cc7341bba55b7946d720e5a8"
  
  func getCityWeather(urlEndPoints: String) -> Future<WeatherInfo, Error> {
    return Future<WeatherInfo, Error> { [weak self] promise in
      guard let self = self, let url = URL(string: self.baseWeatherURL.appending(urlEndPoints).appending(("&appid=\(self.apiKey)"))) else {
        return promise(.failure(NetworkError.invalidURL))
      }
      print("URL is \(url.absoluteString)")
      URLSession.shared.dataTaskPublisher(for: url)
        .tryMap { (data, response) -> Data in
          guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
              throw NetworkError.responseError
          }
          return data
        }
        .decode(type: WeatherInfo.self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { (completion) in
          if case let .failure(error) = completion {
              switch error {
              case let decodingError as DecodingError:
                  promise(.failure(decodingError))
              case let apiError as NetworkError:
                  promise(.failure(apiError))
              default:
                  promise(.failure(NetworkError.unknown))
              }
          }
        }, receiveValue: { promise(.success($0)) })
        .store(in: &self.cancellables)
    }
  }
    
  func getCityName(urlEndPoints: String) -> Future<[CityInfoElement], Error> {
    return Future<[CityInfoElement], Error> { [weak self] promise in
      guard let self = self, let url = URL(string: self.baseCityURL.appending(urlEndPoints).appending("&appid=\(self.apiKey)")) else {
        return promise(.failure(NetworkError.invalidURL))
      }
      print("URL is \(url.absoluteString)")
      URLSession.shared.dataTaskPublisher(for: url)
        .tryMap { (data, response) -> Data in
          guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.responseError
          }
          return data
        }
        .decode(type: [CityInfoElement].self, decoder: JSONDecoder())
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { (completion) in
          if case let .failure(error) = completion {
            switch error {
            case let decodingError as DecodingError:
              promise(.failure(decodingError))
            case let apiError as NetworkError:
              promise(.failure(apiError))
            default:
              promise(.failure(NetworkError.unknown))
            }
          }
        }, receiveValue: { promise(.success($0)) })
        .store(in: &self.cancellables)
    }
  }
}

enum NetworkError: Error {
  case invalidURL
  case responseError
  case unknown
}

extension NetworkError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return NSLocalizedString("Invalid URL", comment: "Invalid URL")
    case .responseError:
      return NSLocalizedString("Unexpected status code", comment: "Invalid response")
    case .unknown:
      return NSLocalizedString("Unknown error", comment: "Unknown error")
    }
  }
}

