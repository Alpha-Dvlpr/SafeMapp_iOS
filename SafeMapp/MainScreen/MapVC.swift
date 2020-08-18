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
    let locationInMeters: Double = 2000
    static let shared: MapVC = MapVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.addViews()
        self.setupConstraints()
        self.checkLocationServices()
        self.addNotificationObservers()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(logoutErrorEvent), name: Notification.Name(rawValue: Notifications.logoutError), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logoutSuccessEvent), name: Notification.Name(rawValue: Notifications.logoutSuccess), object: nil)
    }
    
    private func addViews(){
        view.addSubview(mapView)
        view.addSubview(profileButton)
        view.addSubview(logOutButton)
        view.addSubview(sendAlertButton)
        
        profileButton.isUserInteractionEnabled = true
        logOutButton.isUserInteractionEnabled = true
        sendAlertButton.isUserInteractionEnabled = true
        
        profileButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileButtonPressed)))
        logOutButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logOutButtonPressed)))
        sendAlertButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendAlertButtonPressed)))
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
            self.showAlert(message: NSLocalizedString("locationDisabled", comment: ""))
        }
    }
    
    private func setLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .denied:
            self.showAlert(message: NSLocalizedString("locationDenied", comment: ""))
            break
        case .authorizedWhenInUse:
            self.mapView.showsUserLocation = true
            self.centerUserLocation()
            self.locationManager.startUpdatingLocation()
            break
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            self.showAlert(message: NSLocalizedString("locationRestricted", comment: ""))
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
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("info", comment: ""), message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default) {
            (action) in self.checkLocationServices()
        }
        
        alertController.addAction(okButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func profileButtonPressed() {
        self.present(ProfileVC(), animated: true, completion: nil)
    }
    
    @objc private func logOutButtonPressed() {
        FirebaseManager.logOut(onView: view)
    }
    
    @objc private func sendAlertButtonPressed() {
        MainVC.shared.sendAlertSignal()
    }
    
    @objc private func logoutErrorEvent() {
        self.showAlert(message: NSLocalizedString("logoutError", comment: ""))
    }
    
    @objc private func logoutSuccessEvent() {
        self.present(LoginVC(), animated: true, completion: nil)
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
