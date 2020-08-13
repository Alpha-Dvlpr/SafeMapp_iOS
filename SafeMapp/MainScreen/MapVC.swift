//
//  MapVC.swift
//  SafeMapp
//
//  Created by Aarón on 13/8/20.
//  Copyright © 2020 Aarón. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    let mapView: MKMapView = MKMapView()
    
    let profileButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "user"), for: .normal)
        view.backgroundColor = AppColors.greenColor
        return view
    }()
    
    let logOutButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "logout"), for: .normal)
        
        view.backgroundColor = AppColors.greenColor
        return view
    }()
    
    let sendAlertButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = AppColors.redColor
        return view
    }()
    
    let locationManager: CLLocationManager = CLLocationManager()
    let locationInMeters: Double = 2500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.addViews()
        self.setupConstraints()
        self.checkLocationServices()
    }
    
    private func addViews(){
        view.addSubview(mapView)
        view.addSubview(profileButton)
        view.addSubview(logOutButton)
        view.addSubview(sendAlertButton)
    }
    
    private func setupConstraints() {
        [
            mapView,
            profileButton,
            logOutButton,
            sendAlertButton
        ].forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        
        profileButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        profileButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileButton.widthAnchor.constraint(equalToConstant: 46).isActive = true
        profileButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        profileButton.layer.cornerRadius = 23
        
        logOutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        logOutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        logOutButton.widthAnchor.constraint(equalToConstant: 46).isActive = true
        logOutButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        logOutButton.layer.cornerRadius = 23
        
        sendAlertButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -32).isActive = true
        sendAlertButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        sendAlertButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
        sendAlertButton.heightAnchor.constraint(equalToConstant: 64).isActive = true
        sendAlertButton.layer.cornerRadius = 32
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            self.setLocationManager()
            self.checkLocationAuthorization()
        } else {
            // show alert telling to turn on location service
            print("enable location")
        }
    }
    
    private func setLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            //show alert telling to turn on location, check again on accept
            print("location denied")
            break
        case .authorizedWhenInUse:
            self.mapView.showsUserLocation = true
            self.centerUserLocation()
            self.locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            //locationManager.requestAlwaysAuthorization()
            print("location not determined")
            self.locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            print("location restricted")
            //show alert telling user does not have permission to use location services due to parental control
            break
        default:
            break
        }
    }
    
    private func centerUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: self.locationInMeters, longitudinalMeters: self.locationInMeters)
            self.mapView.setRegion(region, animated: true)
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: self.locationInMeters, longitudinalMeters: self.locationInMeters)
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }
}
