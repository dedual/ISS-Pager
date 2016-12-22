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

class ISSViewAReminderViewController: UITableViewController {
    
    // MARK: - Variables
    
    // shortcuts to text fields
    
    var nameTextField:UITextField!
    var addressTextField:UITextField!
    
    @IBOutlet var mapCell:MapTableViewCell!
    
    weak var tempPlacemark:CLPlacemark?
    {
        didSet
        {
            // create a suitable ISSReminder and update the tableview 
            
            if newReminder != nil, self.tempPlacemark != nil
            {
                if let nameText = nameTextField.text
                {
                    newReminder!.name = nameText
                }
                
                let streetComponent = (tempPlacemark?.subThoroughfare ?? "") + " " + (tempPlacemark?.thoroughfare ?? "")
                let cityComponent = tempPlacemark?.locality ?? ""
                let stateComponent = tempPlacemark?.administrativeArea ?? ""
                let postalCodeComponent = tempPlacemark?.postalCode ?? ""
                let countryCode = tempPlacemark?.country ?? ""
                
                newReminder!.address = streetComponent + " " +
                    cityComponent + ", " +
                    stateComponent + ", " +
                    countryCode + ", " +
                    postalCodeComponent
                
                // do we want to change the user-entered address? To be decided later, Nick.
                
                // should we update the next arrival times here?
                
                self.tableView.reloadData()
            }
        }
    }
    
    var newReminder:ISSReminder?
    
    //MARK: - Initializers
    
    init(placemark:CLPlacemark?)
    {
        super.init(style: .grouped)
        
        self.tempPlacemark = placemark
    }
    
     required convenience init?(coder aDecoder: NSCoder)
    {
        self.init(placemark: nil)
    }
    
    convenience override init(style:UITableViewStyle)
    {
        self.init(placemark: nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        Bundle.main.loadNibNamed("RemindersDetailMainCell", owner: self, options: nil)
        Bundle.main.loadNibNamed("MapCell", owner: self, options: nil)

        self.title = "Reminder"
        // Determine if view is added modally. If so, add close button
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
    
    // MARK: - TableView Delegates and Data Sources
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if (self.tempPlacemark != nil)
        {
            return 5
        }
        else
        {
            return 3
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
        case 3:
            return self.newReminder?.arrivalTimes.count ?? 0
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = ["Name", "Address", "Map", "Next ISS viewing", ""]
        
        return titles[section]
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

extension ISSViewAReminderViewController:UITextFieldDelegate
{
    // remember, we want to update the map and entry every time there's a change
    
    func textFieldDidEndEditing(_ textField: UITextField)
    {
        
    }
}

extension ISSViewAReminderViewController:MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    {
            return (self.tempPlacemark?.location?.coordinate)!
    }
}
