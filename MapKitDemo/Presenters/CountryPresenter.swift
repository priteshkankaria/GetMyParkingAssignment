//
//  CountryPresenter.swift
//  MapKitDemo
//
//  Created by Pritesh Kankaria on 12/04/21.
//

import Foundation

protocol ReloadTableDelegate {
    func reloadTableData(_ countries: [Country])
}

class CountryPresenter {
    let hasLaunchedKey = "hasLaunched"
    let defaults = UserDefaults.standard
    var service = Service.shared
    var reloadTableDelegate: ReloadTableDelegate?

    func loadViews() {
        let hasLaunched = defaults.bool(forKey: hasLaunchedKey)
        if !hasLaunched {
            defaults.set(true, forKey: hasLaunchedKey)
            self.fetchCountriesFromJSON()
        }
        else {
            let countries = service.loadCountriesFromDB()
            reloadTableDelegate?.reloadTableData(countries)
        }
    }

    func fetchCountriesFromJSON(){
        service.clearCountriesFromDB()
        service.fetchCountriesFromJSON(completion: {
            let countries = self.service.loadCountriesFromDB()
            self.reloadTableDelegate?.reloadTableData(countries)
        })
    }
}
