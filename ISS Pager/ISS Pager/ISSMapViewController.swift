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

class ISSMapViewController: UIViewController, MKMapViewDelegate
{

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet var mapView:MKMapView!
    
    var referenceContainerViewController:MainContainerViewController!
    
    var reminders:[ISSReminder]
    {
        return referenceContainerViewController.reminders
    }
    
    func refreshMapAnnotations() // we always worry about our local data
    {
        for anAnnotation in self.mapView.annotations
        {
            self.mapView.removeAnnotation(anAnnotation)
        }
        
        self.mapView.removeOverlays(self.mapView.overlays)
        
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
            return nil
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
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let circleRenderer = MKCircleRenderer(overlay: overlay)
        circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
        circleRenderer.strokeColor = UIColor.blue
        circleRenderer.lineWidth = 1
        return circleRenderer
    }

}
