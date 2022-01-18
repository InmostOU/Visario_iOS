//
//  LocationService.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 17.01.2022.
//

import CoreLocation

final class LocationService: NSObject {
    
    private let manager: CLLocationManager
    private(set) var currentLocation: CLLocation?
    
    private var timer: Timer?

    init(manager: CLLocationManager = .init()) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }

    var newLocation: ((Result<CLLocation, Error>) -> Void)?
    var didChangeStatus: ((Bool) -> Void)?

    var status: CLAuthorizationStatus {
        return CLLocationManager().authorizationStatus
    }

    func requestLocationAuthorization() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }

    func getLocation() {
        manager.requestLocation()
    }
    
    func stoppingGettingLocation() {
        timer?.invalidate()
    }
    
    func startingToGetLocation() {
        getLocation()
        timer = .scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            self.getLocation()
        }
    }

    deinit {
        manager.stopUpdatingLocation()
    }
    
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        newLocation?(.failure(error))
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.sorted(by: {$0.timestamp > $1.timestamp}).first {
            newLocation?(.success(location))
            currentLocation = location
        }
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined, .restricted, .denied:
            didChangeStatus?(false)
        default:
            didChangeStatus?(true)
        }
    }
}
