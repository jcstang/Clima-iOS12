//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    
    
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "708895333ebe328cc344b2e28ba47ac7"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getWeatherData(url: String, parameters: [String: String]) {
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON: JSON = JSON(response.result.value!)
                
                //print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
                self.updateUIWithWeatherData()
                
            }
            else {
                //print("Error \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
            
        }
        
    }

    
    

    //MARK: - JSON Parsing
    /***************************************************************/

    func updateWeatherData(json: JSON) {
        
        if let tempResult = json["main"]["temp"].double {
            
            print(json)
            //weatherDataModel.temperature = Int( tempResult - 273.15 )
            weatherDataModel.temperature = Int( 1.8 * (tempResult - 273.15) ) + 32

            weatherDataModel.city = json["name"].stringValue
            
            weatherDataModel.condition = json["weather"][0]["id"].intValue
            
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
        
        
    }

    
    

    //MARK: - UI Updates
    /***************************************************************/

    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        //temperatureLabel.text = String(weatherDataModel.temperature)
        temperatureLabel.text = "\(weatherDataModel.temperature)°"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //what will happen when if found locations
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil  //stops looking for location
            
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            //cityLabel.text = "\(location.coordinate.longitude) - \(location.coordinate.latitude)"
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params: [String: String] = ["lat": latitude, "lon": longitude, "appid": APP_ID]
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //what will happen when if found locations
        //airplane mode, no internet access.
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    func userEnteredANewCityName(city: String) {
        //print("The name of the city that the user pressed in the last screen is: \(city)")
        let params: [String: String] = ["q": city, "appid": APP_ID]
    }
    
    func randomProtocolThing(name: String) {
        //stuff
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //let destinationVC = segue.destination as! ChangeCityViewController
        let changeCityVC = segue.destination as! ChangeCityViewController
        
        //destinationVC.delegate = self
        changeCityVC.delegate = self
    }
    
    
    
    
}


