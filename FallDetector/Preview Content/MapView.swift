//
//  MapView.swift
//  FallDetector
//
//  Created by André Salgado on 17/11/2022.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
            .onAppear{
                viewModel.checkIfLocationManagerIsEnabled()
            }
            .accentColor(Color(.systemRed))
    }
}

struct MapView_Previews: PreviewProvider {
    var locationManager = CLLocationManager()
    
    func viewDidLoad() {
            locationManager.requestLocation()
        }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.first {
                print("Found user's location: \(location)")
            }
            
        }
   
    
    static var previews: some View {
        MapView()
    }
}

final class ContentViewModel: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    var locationManager: CLLocationManager?
    
    @Published var region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        )
    
    func checkIfLocationManagerIsEnabled(){
        if CLLocationManager.locationServicesEnabled(){
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            
        }else{ print("Turn your location manager on!") }
    }
    
    func  checkLocationAuthorization()  {
        guard let locationManager = locationManager else {return}
        
        switch locationManager.authorizationStatus{
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("No location authorization")
        case .denied:
            print("No location authorization")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location! .coordinate
            , span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
