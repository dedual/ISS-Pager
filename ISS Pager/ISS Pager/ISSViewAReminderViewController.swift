//
//  ISSViewAReminderViewController.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/22/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ISSViewAReminderViewController: UIViewController {
    
    // MARK: - Variables
    
    @IBOutlet var tableView:UITableView!
    
    // shortcuts to text fields
    
    var nameTextField:UITextField!
    var addressTextField:UITextField!
    
    var newReminder:ISSReminder?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(sender:UIButton?)
    {
        self.dismiss(animated: true) { 
            
        }
    }
    
    @IBAction func saveChanges(sender:UIButton?)
    {
        // save changes made to form
        
        // load all saved reminders
        
        // save the new one
        
    }
    
    
    
    
    //MARK: - Forward Geocoding methods
    
    func forwardGeocode(inputAddress:String, completed: @escaping (_ finished:Bool, _ error:Error?, _ placemark:CLPlacemark?) -> ())
    {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(inputAddress) { (placemarks, error) in
            if error != nil
            {
                // handle error here
                
                completed(false, error, nil)
            }
            else
            {
                completed(true, nil, placemarks?.last)
            }
        }
    }
    
    //MARK: - Reverse Geocoding methods
    
    func reverseGeocode(inputCoordinate:CLLocation, completed: @escaping (_ finished:Bool, _ error:Error?, _ placemark:CLPlacemark?) -> ())
    {
        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(inputCoordinate) { (placemarks, error) in
            
            if error != nil
            {
                // handle error here
                
                completed(false, error, nil)
                
            }
            else
            {
                completed(true, nil, placemarks?.last)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

//MARK: UITableView Delegate and Data Source

extension ISSViewAReminderViewController:UITableViewDelegate, UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        <#code#>
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}

extension ISSViewAReminderViewController:UITextFieldDelegate
{
    // remember, we want to update the map and entry every time there's a change
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
    }
}
