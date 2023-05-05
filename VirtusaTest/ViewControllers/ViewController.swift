//
//  ViewController.swift
//  VirtusaTest
//
//  Created by Shailesh Gole on 04/05/23.
//

import UIKit
import Combine

class ViewController: UIViewController {
  
  @IBOutlet weak var weatherIconImageView: UIImageView!
  @IBOutlet weak var degreeLabel: UILabel!
  @IBOutlet weak var tempLabel: UILabel!
  @IBOutlet weak var cityNameLabel: UILabel!
  @IBOutlet weak var weatherDescLabel: UILabel!
  @IBOutlet weak var cityTextField: UITextField!
  
  var viewModel = WeatherInfoViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewModel.updateWeatherDelegate = self
    viewModel.checkForSavedCity()
    addSubscriberforSearch()
  }
  
  @IBAction func searchButtonAction(_ sender: Any) {
    if let cityName = cityTextField.text, cityName != "" {
      viewModel.getWeatherData(forCity: cityName)
    }
  }
  
  func addSubscriberforSearch() {
    cityTextField.textPublisher
      .map { [weak self] searchText in
        if let cityName = searchText, cityName != "" {
          self?.viewModel.getWeatherData(forCity: cityName.trimmingCharacters(in: .whitespaces))
        }
      }
      .sink { [weak self] results in
        self?.updateCityWeather()
      }
      .store(in: &cancellables)
  }
}

extension UITextField {
  var textPublisher: AnyPublisher<String?, Never> {
    NotificationCenter.default.publisher(
      for: UITextField.textDidChangeNotification,
      object: self)
    .map {
      ($0.object as? UITextField)?.text
    }
    .debounce(for: .seconds(2), scheduler: RunLoop.main)
    .removeDuplicates()
    .eraseToAnyPublisher()
  }
}

extension ViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//    if let cityName = cityTextField.text, cityName != "" {
//      let city = cityName.trimmingCharacters(in: .whitespaces)
//      viewModel.getWeatherData(forCity: city)
//    }
    textField.resignFirstResponder()
    return true
  }
}

extension ViewController: UpdateWeatherProtocol {
  
  func updateCityWeather() {
    if let temp = viewModel.weatherInfo?.main.temp, let icon = viewModel.weatherInfo?.weather.first?.icon  {
      let celcius = (temp - 32) * 5/9
      tempLabel.text = String(format: "%.2f °C", celcius)
      cityNameLabel.text = viewModel.weatherInfo?.name
      weatherDescLabel.text = viewModel.weatherInfo?.weather.first?.description
      viewModel.getIconImageForWeather(iconName: icon) { [weak self] data in
        if let self = self, let data = data {
          self.weatherIconImageView.image = UIImage(data: data)
        }
      }
    }
  }
}



