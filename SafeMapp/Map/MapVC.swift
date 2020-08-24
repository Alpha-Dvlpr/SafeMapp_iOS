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
    
    static let shared: MapVC = MapVC()
    let locationManager: CLLocationManager = CLLocationManager()
    let locationInMeters: Double = 2500
    let defaultRadius: Double = 500
    var currentLocation: CLLocation!
    var locationToChange: CLLocation!
    var directionsArray: [MKDirections] = []
    var mapCircle: MKCircle!
    var buttonPressed: Bool = false
    var viewModel: MainVM!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        self.addNotificationObservers()
        self.addViews()
        self.setupConstraints()
        self.checkLocationServices()
        self.setupIntents()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupVM(viewModel: MainVM) {
        self.viewModel = viewModel
    }
    
    private func addNotificationObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(logoutErrorEvent), name: Notification.Name(rawValue: Notifications.logoutError), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logoutSuccessEvent), name: Notification.Name(rawValue: Notifications.logoutSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendAlertSignalEvent), name: Notification.Name(rawValue: Notifications.sendAlertSignal), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendLongAlertSignalStartEvent), name: Notification.Name(rawValue: Notifications.sendLongAlertSignalStart), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sendLongAlertSignalEndEvent), name: Notification.Name(rawValue: Notifications.sendLongAlertSignalEnd), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(requestAccepted(_:)), name: NSNotification.Name(rawValue: Notifications.requestAccepted), object: nil)
    }
    
    @objc private func logoutErrorEvent() {
        self.showAlert(message: NSLocalizedString("logoutError", comment: ""))
    }

    @objc private func logoutSuccessEvent() {
        self.present(LoginVC(), animated: true, completion: nil)
    }
    
    @objc private func sendAlertSignalEvent() {
        var retryCount: Int = 3
        
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (timer) in
            if self.viewModel.usersFetched {
                timer.invalidate()
                
                self.addCircleToMap(radiusValue: self.defaultRadius)
                self.sendAlertSignal(distance: self.defaultRadius)
                self.resetMapCircle()
            }
            
            if retryCount == 0 {
                timer.invalidate()
                ToastNotification.shared.long(self.view, txt_msg: NSLocalizedString("couldNotGetNearbyUsersRetry", comment: ""))
            }
            
            ToastNotification.shared.short(self.view, txt_msg: NSLocalizedString("gettingNearbyUsersRetrying", comment: ""))
            retryCount -= 1
        }
    }
    
    @objc private func sendLongAlertSignalStartEvent() {
        self.buttonPressed = true
        self.startPressCount()
    }
    
    @objc private func sendLongAlertSignalEndEvent() {
        self.buttonPressed = false
    }
    
    @objc private func requestAccepted(_ notification: NSNotification) {
        if let info = notification.userInfo {
            if let row: Int = info["index"] as? Int {
                if self.viewModel.requests.isEmpty {
                    ToastNotification.shared.long(self.view, txt_msg: "No hay solicitudes disponibles")
                } else {
                    if row > (self.viewModel.requests.count - 1) {
                        ToastNotification.shared.long(self.view, txt_msg: "Error al obtener la ruta")
                    } else {
                        let request = self.viewModel.requests[row]
                        let coordinate = CLLocation(latitude: request.latitude, longitude: request.longitude)
                        
                        let mapRequest = self.createLocationMapRequest(from: coordinate.coordinate)
                        let mapDirections = MKDirections(request: mapRequest)
                        self.resetMapViews(with: mapDirections)
                        
                        mapDirections.calculate { [unowned self] (response, error) in
                            if error != nil {
                                ToastNotification.shared.long(self.view, txt_msg: (error?.localizedDescription)!)
                                return
                            }
                            
                            guard let response = response else { return }
                            
                            for route in response.routes {
                                self.mapView.addOverlay(route.polyline)
                                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                            }
                            
                            //TODO: delete from viewmodel and update firebase database
                        }
                    }
                }
            }
        }
    }
    
    private func createLocationMapRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate = coordinate
        let startingLocation = MKPlacemark(coordinate: self.currentLocation.coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .walking
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    private func resetMapViews(with newDirections: MKDirections) {
        self.mapView.removeOverlays(self.mapView.overlays)
        directionsArray.append(newDirections)
        let _ = directionsArray.map{ $0.cancel() }
    }
    
    private func addViews(){
        view.addSubview(mapView)
        view.addSubview(profileButton)
        view.addSubview(logOutButton)
        view.addSubview(sendAlertButton)
        
        self.mapView.delegate = self
        
        profileButton.isUserInteractionEnabled = true
        logOutButton.isUserInteractionEnabled = true
        sendAlertButton.isUserInteractionEnabled = true
        
        profileButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileButtonPressed)))
        logOutButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logOutButtonPressed)))
        sendAlertButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sendAlertButtonPressed)))
        sendAlertButton.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(sendLongAlertSignalEvent(gesture:))))
    }

    @objc private func profileButtonPressed() {
        self.present(ProfileVC(), animated: true, completion: nil)
    }
    
    @objc private func logOutButtonPressed() {
        FirebaseManager.logOut(onView: view)
    }
    
    @objc private func sendAlertButtonPressed() {
        self.addCircleToMap(radiusValue: self.defaultRadius)
        self.sendAlertSignal(distance: self.defaultRadius)
        self.resetMapCircle()
    }
    
    @objc private func sendLongAlertSignalEvent(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began { NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.sendLongAlertSignalStart))) }
        if gesture.state == .ended { NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: Notifications.sendLongAlertSignalEnd))) }
    }
    
    private func startPressCount() {
        var distance: Double = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (timer) in
            if !self.buttonPressed {
                timer.invalidate()
                self.resetMapCircle()
                self.sendAlertSignal(distance: distance)
            }
            
            distance += 25
            self.addCircleToMap(radiusValue: distance)
            
            if distance == 1000 {
                timer.invalidate()
                self.resetMapCircle()
                self.sendAlertSignal(distance: distance)
            }
        }
    }
    
    public func sendAlertSignal(distance: Double) {
        //TODO: Enviar alerta
        //TODO: Cambiar imagen del botón
        //TODO: Configurar notificaciones
        var nearUsers: [User] = []
        
        for user in self.viewModel.nearUsers {
            let ul: CLLocation = CLLocation(latitude: user.latitude, longitude: user.longitude)
            
            if self.currentLocation.distance(from: ul) <= distance {
                nearUsers.append(user)
            }
        }
        
        if nearUsers.count == 0 {
            ToastNotification.shared.long(view, txt_msg: NSLocalizedString("noUsersNearbyIncrease", comment: ""))
        } else {
            
            
            
            ToastNotification.shared.long(view, txt_msg: "\(NSLocalizedString("sendingAlert", comment: "")) (\(nearUsers.count)). \(Int(distance)) \(NSLocalizedString("meters", comment: ""))")
        }
    }
    
    private func addCircleToMap(radiusValue: Double){
        if self.mapCircle != nil { self.mapView.removeOverlay(self.mapCircle) }
        self.mapCircle = MKCircle(center: self.currentLocation.coordinate, radius: radiusValue as CLLocationDistance)
        self.mapView.addOverlay(self.mapCircle)
    }
    
    private func resetMapCircle() {
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
            if self.mapCircle != nil { self.mapView.removeOverlay(self.mapCircle) }
        }
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
            self.centerUserLocation(distance: self.locationInMeters)
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
    
    private func centerUserLocation(distance: Double) {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: distance, longitudinalMeters: distance)
            self.mapView.setRegion(region, animated: true)
            self.currentLocation = locationManager.location
            self.locationToChange = locationManager.location
            
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: Notifications.userDidSetupLocation),
                object: nil,
                userInfo: [ "location": locationManager.location! ]
            )
            
            FirebaseManager.updateUserLocation(longitude: location.longitude, latitude: location.latitude)
        }
    }
    
    private func setupIntents() {
        let activity = NSUserActivity(activityType: "com.alpha-dvlpr.SafeMapp.sayHi")
        activity.title = NSLocalizedString("safeMappAlert", comment: "")
        activity.userInfo = ["speech" : "hi"]
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier("com.alpha-dvlpr.SafeMapp.sayHi")
        view.userActivity = activity
        activity.becomeCurrent()
    }
    
    private func showAlert(message: String) {
        let alertController = UIAlertController(title: NSLocalizedString("info", comment: ""), message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: NSLocalizedString("accept", comment: ""), style: .default) {
            (action) in self.checkLocationServices()
        }
        
        alertController.addAction(okButton)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func calculateDistance(l1: CLLocation, l2: CLLocation) -> Double {
        return l1.distance(from: l2)
    }
}

extension MapVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: self.locationInMeters, longitudinalMeters: self.locationInMeters)
        self.mapView.setRegion(region, animated: true)
        self.currentLocation = location
        
        if self.calculateDistance(l1: self.locationToChange, l2: location) >= 10 {
            self.locationToChange = location
            
            NotificationCenter.default.post(
                name: Notification.Name(rawValue: Notifications.userDidChangeLocation),
                object: nil,
                userInfo: ["location": location]
            )
            
            FirebaseManager.updateUserLocation(longitude: self.locationToChange.coordinate.longitude, latitude: self.locationToChange.coordinate.latitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkLocationAuthorization()
    }
}

extension MapVC: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKCircle:
            let circle = MKCircleRenderer(overlay: overlay)
            circle.strokeColor = UIColor.red
            circle.fillColor = UIColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 0.8)
            circle.lineWidth = 1
            return circle
        case is MKPolyline:
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = AppColors.redColor
            return renderer
        default:
            return MKOverlayRenderer()
        }
    }
}
