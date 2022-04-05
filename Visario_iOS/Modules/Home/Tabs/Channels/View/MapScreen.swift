//
//  MapScreen.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 26.10.2021.
//

import MapKit
import CoreLocation

protocol MapsDelegate: AnyObject {
    /**
     Returns coordinates of the selected place on map
     - Parameter coordinates: place coordinates
     */
    func selectLocation(coordinate: CLLocationCoordinate2D)
}

final class MapScreen: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: MapsDelegate?
    
    private let locationManager = CLLocationManager()
    private let mapsViewModel = MapsViewModel()
    
    private var mapType: MKMapType = .standard
    private let mapControlButtonWidth: CGFloat = 50
    private let backButtonWidth: CGFloat = 40
    private let defaultInset: CGFloat = 16
    private var regionInMeters: Double = 10_000
    private var selectedLocation: CLLocationCoordinate2D?
    private var searchQuery = ""
    
    var zoomLevel: Double {
        var angleCamera = mapView.camera.heading
        if angleCamera > 270 {
            angleCamera = 360 - angleCamera
        } else if angleCamera > 90 {
            angleCamera = fabs(angleCamera - 180)
        }
        let angleRad = Double.pi * angleCamera / 180
        let width = Double(self.view.frame.size.width)
        let height = Double(self.view.frame.size.height)
        let heightOffset = 20.0
        let spanStraight = width * mapView.region.span.longitudeDelta / (width * cos(angleRad) + (height - heightOffset) * sin(angleRad))
        return log2(360 * ((width / 256) / spanStraight)) + 1
    }
    
    // MARK: - UI Elements
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundColor = .white
        button.tintColor = .black
        button.layer.cornerRadius = backButtonWidth / 2
        button.layer.masksToBounds = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = mapControlButtonWidth / 2
        button.layer.masksToBounds = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        let inset = mapControlButtonWidth / 4
        button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        button.addTarget(self, action: #selector(goToUserLocation), for: .touchUpInside)
        return button
    }()
    
    private lazy var mapTypeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "network"), for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = mapControlButtonWidth / 2
        button.layer.masksToBounds = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        let inset = mapControlButtonWidth / 4
        button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        button.addTarget(self, action: #selector(updateMapType), for: .touchUpInside)
        return button
    }()
    
    private lazy var zoomInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = mapControlButtonWidth / 2
        button.layer.masksToBounds = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        let inset = mapControlButtonWidth / 4
        button.contentEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        button.addTarget(self, action: #selector(mapZoomIn), for: .touchUpInside)
        return button
    }()
    
    private lazy var zoomOutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "minus"), for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = mapControlButtonWidth / 2
        button.layer.masksToBounds = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        let inset = mapControlButtonWidth / 4
        button.contentEdgeInsets = UIEdgeInsets(top: inset + 10, left: inset, bottom: inset + 10, right: inset)
        button.addTarget(self, action: #selector(mapZoomOut), for: .touchUpInside)
        return button
    }()
    
    private lazy var chevronButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = mapControlButtonWidth / 2
        button.layer.masksToBounds = true
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        let inset = mapControlButtonWidth / 4
        button.contentEdgeInsets = UIEdgeInsets(top: inset * 1.5, left: inset, bottom: inset * 1.5, right: inset)
        button.addTarget(self, action: #selector(chevronButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var mapControlButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alpha = 0
        return stackView
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(tapPlaceHandler))
        return tapGesture
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.addGestureRecognizer(tapGesture)
        return mapView
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = backButtonWidth / 2
        button.layer.masksToBounds = true
        button.tintColor = .black
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.backgroundColor = .black
        button.alpha = 0
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search"
        textField.layer.cornerRadius = backButtonWidth / 2
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.addTarget(self, action: #selector(searchFieldDidChange), for: .editingChanged)
        textField.innerPaddings(left: defaultInset, right: backButtonWidth)
        return textField
    }()
    
    private lazy var placesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var searchStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = .white
        stackView.layer.cornerRadius = backButtonWidth / 2
        stackView.layer.masksToBounds = true
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        configureConstraints()
        setupLocationManager()
        checkLocationServices()
    }
    
    private func setupViews() {
        view.addSubview(mapView)
        view.addSubview(backButton)
        view.addSubview(mapControlButtonsStackView)
        view.addSubview(doneButton)
        view.addSubview(searchStackView)
        view.addSubview(searchButton)
        view.addSubview(chevronButton)
        
        mapControlButtonsStackView.addArrangedSubview(zoomInButton)
        mapControlButtonsStackView.addArrangedSubview(zoomOutButton)
        mapControlButtonsStackView.addArrangedSubview(locationButton)
        mapControlButtonsStackView.addArrangedSubviews(mapTypeButton)
        
        searchStackView.addArrangedSubview(searchTextField)
        searchStackView.addArrangedSubview(placesTableView)
        searchStackView.sendSubviewToBack(placesTableView)
    }
    
    private func configureConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        backButton.snp.makeConstraints {
            $0.width.height.equalTo(backButtonWidth)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.leading.equalToSuperview().offset(defaultInset)
        }
        chevronButton.snp.makeConstraints {
            $0.width.height.equalTo(mapControlButtonWidth)
            $0.trailing.equalToSuperview().inset(defaultInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(50)
        }
        //------ control buttons stack view --------
        zoomInButton.snp.makeConstraints {
            $0.width.height.equalTo(mapControlButtonWidth)
        }
        zoomOutButton.snp.makeConstraints {
            $0.width.height.equalTo(mapControlButtonWidth)
        }
        mapTypeButton.snp.makeConstraints {
            $0.width.height.equalTo(mapControlButtonWidth)
        }
        locationButton.snp.makeConstraints {
            $0.width.height.equalTo(mapControlButtonWidth)
        }
        mapControlButtonsStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(defaultInset)
            $0.bottom.equalTo(chevronButton.snp.top).offset(-10)
        }
        // ------ done button -------
        doneButton.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(40)
            $0.leading.equalToSuperview().offset(defaultInset)
            $0.bottom.equalTo(chevronButton.snp.bottom)
        }
        // ------- search bar stack view --------
        searchButton.snp.makeConstraints {
            $0.width.height.equalTo(backButtonWidth)
            $0.top.equalTo(backButton)
            $0.trailing.equalToSuperview().inset(defaultInset)
        }
        searchTextField.snp.makeConstraints {
            $0.height.equalTo(backButtonWidth)
            $0.leading.trailing.equalToSuperview()
        }
        placesTableView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0)
        }
        searchStackView.snp.makeConstraints {
            $0.trailing.equalTo(searchButton.snp.trailing)
            $0.top.equalTo(backButton)
            $0.width.equalTo(0)
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            startTrackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        @unknown default:
            // There must be ErrorAlert
            break
        }
    }
    
    private func startTrackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func centerViewOnUserLocation() {
        guard let coordinate = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    private func setNewLocation(by tapLocation: CGPoint) {
        let locationCoordinate = mapView.convert(tapLocation, toCoordinateFrom: mapView)
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        selectedLocation = locationCoordinate
        
        showDoneButton()
        
        // convert from coordinate to place description
        CLGeocoder().reverseGeocodeLocation(location) { [weak self] marks, error in
            guard error == nil, let self = self else { return }
            guard let placeMark = marks?.first else { return }
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = locationCoordinate
            annotation.title = placeMark.locality
            annotation.subtitle = placeMark.name
            
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(annotation)
        }
    }
    
    private func sendLocationToDelegate(location: CLLocationCoordinate2D) {
        guard let delegate = delegate else {
            print("Delegate not exist!")
            return }
        delegate.selectLocation(coordinate: location)
    }
    
    private func showDoneButton() {
        UIView.animate(withDuration: 0.5) {
            self.doneButton.alpha = 1
        }
    }
    
    private func showHideSearchField() {
        self.searchStackView.snp.updateConstraints {
            if self.searchStackView.frame.width == 0 {
                let width = UIScreen.main.bounds.width - (self.backButtonWidth + self.defaultInset * 3)
                $0.width.equalTo(width)
                self.searchTextField.becomeFirstResponder()
            } else {
                $0.width.equalTo(0)
                self.searchTextField.resignFirstResponder()
            }
        }
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showPlacesTableView(show: Bool) {
        UIView.animate(withDuration: 0.2) {
            self.placesTableView.snp.updateConstraints {
                $0.height.equalTo(show ? 500 : 0)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func selectPlace(place: MKPlacemark) {
        guard let coordinate = place.location?.coordinate else { return }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.subtitle = place.name
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(annotation)
        mapView.showAnnotations([annotation], animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapScreen: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

// MARK: - Objc Actions

@objc extension MapScreen {
    
    private func tapPlaceHandler(sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: mapView)
        setNewLocation(by: tapLocation)
        view.endEditing(true)
    }
    
    private func backButtonTapped() {
        dismiss(animated: true)
    }
    
    private func goToUserLocation() {
        centerViewOnUserLocation()
    }
    
    private func updateMapType() {
        switch mapType {
        case .standard:
            mapType = .hybrid
            mapView.mapType = mapType
            mapTypeButton.setImage(UIImage(systemName: "map"), for: .normal)
        case .hybrid:
            mapType = .standard
            mapView.mapType = mapType
            mapTypeButton.setImage(UIImage(systemName: "network"), for: .normal)
        default:
            break
        }
    }
    
    private func doneButtonTapped() {
        guard let location = selectedLocation else { return }
        sendLocationToDelegate(location: location)
        dismiss(animated: true)
    }
    
    private func searchButtonTapped() {
        showHideSearchField()
    }
    
    private func searchFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        searchQuery = text
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.search(by: text)
        }
    }
    
    private func search(by query: String) {
        mapsViewModel.search(by: query) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                guard !self.searchQuery.isEmpty else { return }
                self.placesTableView.reloadData()
                self.showPlacesTableView(show: true)
            case .failure(let error):
                self.showPlacesTableView(show: false)
                print(error)
            }
        }
    }
    
    private func mapZoomIn() {
        var span = MKCoordinateSpan()
        span.latitudeDelta = mapView.region.span.latitudeDelta / 2
        span.longitudeDelta = mapView.region.span.longitudeDelta / 2
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func mapZoomOut() {
        guard zoomLevel > 4 else { return }
        var span = MKCoordinateSpan()
        span.latitudeDelta = mapView.region.span.latitudeDelta * 2
        span.longitudeDelta = mapView.region.span.longitudeDelta * 2
        let region = MKCoordinateRegion(center: mapView.region.center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    private func chevronButtonTapped() {
        let stackAlpha = mapControlButtonsStackView.alpha
        self.chevronButton.transform = CGAffineTransform(rotationAngle: stackAlpha == 0 ? .pi : .zero)
        
        UIView.animate(withDuration: 0.5) {
            self.mapControlButtonsStackView.alpha = stackAlpha == 0 ? 1 : 0
        }
    }
}

// MARK: - UITabelViewDelegate

extension MapScreen: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        showHideSearchField()
        
        let place = mapsViewModel.placeMarks[indexPath.row]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.selectPlace(place: place)
        }
    }
    
}

// MARK: - UITabelViewDataSource

extension MapScreen: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapsViewModel.placeMarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Place")
        
        let placeMark = mapsViewModel.placeMarks[indexPath.row]
        
        cell.textLabel?.text = placeMark.name
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = placeMark.administrativeArea
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
    
}
