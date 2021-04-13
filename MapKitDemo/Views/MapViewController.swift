//
//  ViewController.swift
//  MapKitDemo
//
//  Created by Pritesh Kankaria on 11/04/21.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps
import CoreData

class MapViewController: UIViewController {
    @IBOutlet weak var countriesTableView: UITableView!
    @IBOutlet weak var googleMapView: UIView!

    lazy var countries = [Country]()
    
    let countryPresenter = CountryPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        countriesTableView.delegate = self
        countriesTableView.dataSource = self
        countryPresenter.reloadTableDelegate = self

        countryPresenter.loadViews()
    }

    @IBAction func refreshButton(_ sender: UIBarButtonItem) {
        countries.removeAll()
        countryPresenter.fetchCountriesFromJSON()
    }

    func showAllCountriesInMap() {
        let camera = GMSCameraPosition.camera(withLatitude: 0.0, longitude: 0.0, zoom: 1.0)
        let mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        googleMapView.addSubview(mapView)
        for country in countries {
            let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(country.latitude),
                                                                            longitude: CLLocationDegrees(country.longitude))
            let marker = GMSMarker()
            marker.position = coordinate
            marker.map = mapView
            //marker.icon = #imageLiteral(resourceName: "Map-Marker")
        }
    }

    func showParticularMap(using country: Country) {
        let countryName = country.name
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: CLLocationDegrees(country.latitude),
                                                                        longitude: CLLocationDegrees(country.longitude))
        let mapView = GMSMapView(frame: self.view.frame)
        mapView.animate(to: GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                                                      longitude: coordinate.longitude,
                                                      zoom: 5.0))
        googleMapView.addSubview(mapView)

        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = countryName
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: .green)
    }
}


extension MapViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = countriesTableView.dequeueReusableCell(withIdentifier: "CountryCell", for: indexPath)
        cell.textLabel?.text = countries[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = countries[indexPath.row]
        showParticularMap(using: country)
    }
}

extension MapViewController: ReloadTableDelegate {
    func reloadTableData(_ countries: [Country]) {
        self.countries = countries
        DispatchQueue.main.async {
            self.countriesTableView.reloadData()
            self.showAllCountriesInMap()
        }
    }
}
