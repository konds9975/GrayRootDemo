//
//  ViewController.swift
//  GrayRootDemo
//
//  Created by Kondya on 13/06/19.
//  Copyright © 2019 Kondya. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationArray : [CLLocationCoordinate2D] = []
    var pinNameArray = ["First location","Second location","Third location","Fourth location"]
    var isCreate = false
    
    var pinCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.mapView.mapType = MKMapType.standard
        self.mapView.showsUserLocation = true
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        self.mapView.addGestureRecognizer(longTapGesture)
        
    }
    
    @IBAction func createBtnAction(_ sender: UIBarButtonItem) {
        self.isCreate = true
        let allAnnotations = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotations)
        self.locationArray.removeAll()
        self.pinCount = 0
        self.mapView.removeOverlays(self.mapView.overlays)
        
    }
    func saveAlert()  {
        let alertController = UIAlertController(title: "Enter Area Name", message: "", preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Enter Area Name"
        }
        let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
            
            let firstTextField = alertController.textFields![0] as UITextField
            
            if !(firstTextField.text!.trimmingCharacters(in: .whitespaces).isEmpty) {
                self.isCreate = true
                
            }
            
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: {
            (action : UIAlertAction!) -> Void in
            
            self.isCreate = false
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
            self.locationArray.removeAll()
            self.pinCount = 0
            self.mapView.removeOverlays(self.mapView.overlays)
            
        })
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    @objc func longTap(sender: UIGestureRecognizer){
        print("long tap")
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
    }
    func addAnnotation(location: CLLocationCoordinate2D){
        
        if self.isCreate {
            if self.pinCount <= 3 {
                let annotation = MKPointAnnotation()
                annotation.coordinate = location
                //let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                self.locationArray.append(location)
                annotation.title = self.pinNameArray[pinCount]
                self.mapView.addAnnotation(annotation)
                if self.pinCount == 3 {
                    self.showRouteOnMap(pickupCoordinate: self.locationArray[0], destinationCoordinate: self.locationArray[1])
                    self.showRouteOnMap(pickupCoordinate: self.locationArray[1], destinationCoordinate: self.locationArray[2])
                    self.showRouteOnMap(pickupCoordinate: self.locationArray[2], destinationCoordinate: self.locationArray[3])
                    self.showRouteOnMap(pickupCoordinate: self.locationArray[3], destinationCoordinate: self.locationArray[0])
                    self.saveAlert()
                    
                }
                pinCount += 1
                
            }else{
                
            }
        }
        
    }
    func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
        
        let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            
            self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 2.0
        
        return renderer
    }

    
}
extension  MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { print("no mkpointannotaions"); return nil }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("tapped on pin ")
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
        }
    }
}
