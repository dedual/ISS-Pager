//
//  ISSMapViewController.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ISSMapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate
{
    let locationManager = CLLocationManager()
    
    @IBOutlet var mapView:MKMapView!
    
    var currISSLocation:ISSLocation!
    var myLocation:CLLocationCoordinate2D?

    
    var referenceContainerViewController:MainContainerViewController!
    
    var reminders:[ISSReminder]
    {
        return referenceContainerViewController.reminders
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.locationManager.requestWhenInUseAuthorization()
        

        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshISSLocation()
    {
        ISSNetwork.request(target: .CurrentLocation(), success: { json in
            if let jsonObject = json as? [String:AnyObject]
            {
                self.currISSLocation = ISSLocation(json: jsonObject)
                
                for anAnnotation in self.mapView.annotations
                {
                    if anAnnotation is ISSLocationAnnotation
                    {
                        self.mapView.removeAnnotation(anAnnotation)
                    }
                }
                self.mapView.removeOverlays(self.mapView.overlays)

                let identifier = "ISSLocation"
                let annotation = ISSLocationAnnotation(coordinate: self.currISSLocation.currLocation.coordinate, identifier: identifier, location: self.currISSLocation)
                
                self.mapView.addAnnotation(annotation)
                
                let circle = MKCircle(center: annotation.coordinate, radius: 80000.0)
                
                self.mapView.add(circle)
                
                
            }
        }, error: { response in
            
        }) { error in
            
        }
    }
    
    func refreshMapAnnotations() // we always worry about our local data
    {
        for anAnnotation in self.mapView.annotations
        {
            self.mapView.removeAnnotation(anAnnotation)
        }
        
        // add placepoints here
        
        for aReminder in reminders
        {
            let identifier = "reminder_\(aReminder.location.coordinate.latitude)\(aReminder.location.coordinate.longitude)\(aReminder.lastUpdated.humanReadableDate)"
            
            let annotation = ISSReminderAnnotation(coordinate: aReminder.location.coordinate, identifier: identifier, reminder: aReminder)
            self.mapView.addAnnotation(annotation)
            
        }
        
    }
    
    //MARK: - MKMapViewDelegate function
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation is MKUserLocation
        {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "User")

            annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "User")
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return annotationView
        }
        
        if annotation is ISSReminderAnnotation
        {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
            
            if annotationView == nil
            {
                annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "Pin")
                annotationView?.canShowCallout = true
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
            }else
            {
                annotationView?.annotation = annotation
            }
            
            annotationView?.image = UIImage(named: "RemindersIcon")
            
            return annotationView
            
        }
        else if annotation is ISSLocationAnnotation
        {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "ISS")
            
            if annotationView == nil
            {
                annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "ISS")
                annotationView?.canShowCallout = true
            }else
            {
                annotationView?.annotation = annotation
            }
            annotationView?.image = UIImage(named: "ISSIcon")
            
            return annotationView
        }
        else
        {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl)
    {
        let items = NSMutableArray()
        for aReminder in reminders {
            let item = NSKeyedArchiver.archivedData(withRootObject: aReminder)
            items.add(item)
        }
        
        UserDefaults.standard.set(items, forKey: kSavedItemsKey)
        UserDefaults.standard.synchronize()
        
        let selectedReminder = (view.annotation as! ISSReminderAnnotation).reminder!
        
        // Set up the detail view controller to show.
        let detailViewController = ISSViewAReminderViewController.detailViewControllerForReminder(selectedReminder)
        
        referenceContainerViewController.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func mapView(_ mapView: MKMapView,
                 didSelect view: MKAnnotationView)
    {
        
    }
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.isKind(of: AnnotationView.self)
        {
            for subview in view.subviews
            {
                subview.removeFromSuperview()
            }
        }
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool)
    {
        self.refreshMapAnnotations()
        self.refreshISSLocation()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
        circleRenderer.strokeColor = UIColor.blue
        circleRenderer.lineWidth = 1
        return circleRenderer
    }
    
    //MARK: - Location Manager Delegates
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if(status == .authorizedWhenInUse)
        {
            self.refreshMapAnnotations()
            self.refreshISSLocation()
        }
        else
        {
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to be notified of when the ISS is near you, please open this app's settings and set location access to 'When in Use'.",
                preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
                if let url = URL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }

}
