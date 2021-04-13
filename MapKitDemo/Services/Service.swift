//
//  Service.swift
//  MapKitDemo
//
//  Created by Pritesh Kankaria on 12/04/21.
//

import Foundation
import Alamofire
import SwiftyJSON
import GoogleMaps
import CoreData

struct Service {
    static let shared = Service()
    let url = "https://restcountries.eu/rest/v2/all"
    lazy var countries = [Country]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    func fetchCountriesFromJSON(completion: @escaping ()->()) {
        let request = AF.request(url)
        request.responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                for index in 0..<json.count {
                    if let name = json[index]["name"].string,
                       let lat = json[index]["latlng"][0].int,
                       let lng = json[index]["latlng"][1].int {
                        self.insertCountryToDB(countryName: name, latitude: lat, longitude: lng)
                    }
                }
                completion()
            case .failure(let error):
                print(error)
            }
        }
    }

    func insertCountryToDB(countryName: String, latitude: Int, longitude: Int) {
        let country = Country(context: self.context)
        country.name = countryName
        country.latitude = Int16(latitude)
        country.longitude = Int16(longitude)
        do {
            try context.save()
        } catch {
            print("Error while saving: \(error)")
        }
    }

    mutating func loadCountriesFromDB() -> [Country]{
        let request: NSFetchRequest<Country> = Country.fetchRequest()
        do {
            countries = try context.fetch(request)
        } catch {
            print("Error while fetching: \(error)")
        }
        return countries
    }

    func clearCountriesFromDB() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Country")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(batchDeleteRequest)
        } catch {
            print("Error while deleting: \(error)")
        }
    }
}
