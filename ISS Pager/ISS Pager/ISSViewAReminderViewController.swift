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

// note: we need to confirm that whenever we update a reminder we're updating, not instantiating a new one. -Nick D.

class ISSViewAReminderViewController: UITableViewController {
    
    // MARK: - Variables
    
    // shortcuts to text fields
    
    var nameTextField:UITextField!
    var addressTextField:UITextField!
    
    @IBOutlet var mapCell:MapTableViewCell!
    
    var tempPlacemark:CLPlacemark?
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
                
            }
        }
    }
    
    var newReminder:ISSReminder?
    
    //MARK: - Initializers
    
    class func detailViewControllerForReminder(_ reminder: ISSReminder) -> ISSViewAReminderViewController {
        
        let viewController = ISSViewAReminderViewController(reminder: reminder)
                
        return viewController
    }
    
    init(placemark:CLPlacemark? = nil, reminder:ISSReminder? = nil)
    {
        super.init(style: .grouped)
        
        self.newReminder = reminder ?? ISSReminder()
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
        
        let dismissButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ISSViewAReminderViewController.close(_:)))
        
        if(self.isModal())
        {
            self.navigationItem.leftBarButtonItem = dismissButton
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func close(_ sender:UIButton?)
    {
        self.dismiss(animated: true)
        {
            
        }
    }
    
    @IBAction func saveChanges(sender:UIButton?)
    {
        // save changes made to form
        
        // load all saved reminders

        var allReminders:[ISSReminder] = []
        
        if let savedItems = UserDefaults.standard.array(forKey: kSavedItemsKey)
        {
            for savedItem in savedItems
            {
                if let regionToMonitor = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? ISSReminder
                {
                    allReminders.append(regionToMonitor)
                }
            }
        }
        
        // save the new one

        if let reminder = self.newReminder
        {
            allReminders.append(reminder)
            
            let items = NSMutableArray()
            for aReminder in allReminders {
                let item = NSKeyedArchiver.archivedData(withRootObject: aReminder)
                items.add(item)
            }
            
            UserDefaults.standard.set(items, forKey: kSavedItemsKey)
            UserDefaults.standard.synchronize()
        }
        else
        {
            // throw alert here. Something's wrong
        }
        
    }
    
    func isModal() -> Bool {
        if self.presentingViewController != nil {
            return true
        } else if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        } else if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
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
    // we might need to move this one away from here, it's not being used right now and proably will be later on. 
    
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
    
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        if self.tempPlacemark != nil || self.newReminder?.arrivalTimes != nil
        {
            return (self.newReminder?.arrivalTimes!.count)! > 0 ? 5 : 3
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
            return (self.newReminder?.arrivalTimes!.count)!
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch(indexPath.section)
        {
        case 0: // Name
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "RemindersDetailMainCell") as? RemindersDetailMainCell
            
            if cell == nil
            {
                tableView.register(UINib(nibName: "RemindersDetailMainCell", bundle: nil), forCellReuseIdentifier: "RemindersDetailMainCell")
                cell = tableView.dequeueReusableCell(withIdentifier: "RemindersDetailMainCell") as? RemindersDetailMainCell
            }
            
            cell!.label.text = "Name"
            
            if let name = self.newReminder?.name
            {
                cell!.textfield.text = name
            }
            else
            {
                cell!.textfield.placeholder = "Enter a name here"
            }
            
            self.nameTextField = cell!.textfield // for quick reference
            self.nameTextField.delegate = self
            
            return cell!
            
        case 1: // Address
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "RemindersDetailMainCell") as? RemindersDetailMainCell
            
            if cell == nil
            {
                tableView.register(UINib(nibName: "RemindersDetailMainCell", bundle: nil), forCellReuseIdentifier: "RemindersDetailMainCell")
                cell = tableView.dequeueReusableCell(withIdentifier: "RemindersDetailMainCell") as? RemindersDetailMainCell
            }
            
            cell!.label.text = "Address"
            
            if let address = self.newReminder?.address
            {
                cell!.textfield.text = address
            }
            else
            {
                cell!.textfield.placeholder = "Enter an address here"
            }
            
            self.addressTextField = cell!.textfield // for quick reference
            self.addressTextField.delegate = self
            
            return cell!
            
        case 2: // Map
            
            if tempPlacemark != nil
            {
                // point the map to our placemark
                
                let region = MKCoordinateRegionMakeWithDistance(self.tempPlacemark!.location!.coordinate, 200, 200); // not entirely safe, I know
                self.mapCell.mapview.region = region;
            
                // add a pin using self as the object implementing the MKAnnotation protocol
                self.mapCell.mapview.addAnnotation(self)
                
                return self.mapCell;
            }
            else if let count = self.newReminder?.arrivalTimes?.count, count > 0
            {
                let region = MKCoordinateRegionMakeWithDistance(self.newReminder!.location.coordinate, 200, 200); // not entirely safe, I know
                self.mapCell.mapview.region = region;
                
                // add a pin using self as the object implementing the MKAnnotation protocol
                self.mapCell.mapview.addAnnotation(self)
                
                return self.mapCell;
            }
            else
            {
                //save button goes here
                
                var cell = tableView.dequeueReusableCell(withIdentifier: "basicCellButton")
                
                if cell == nil
                {
                    cell = UITableViewCell(style: .default, reuseIdentifier: "basicCellButton")
                    cell?.selectionStyle = .none
                }
                if let subviews = cell?.contentView.subviews // make sure that nothing funky's going on with how Apple preserves views
                {
                    for aSubview in subviews
                    {
                        aSubview.removeFromSuperview()
                    }
                }
                
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height:44))
                
                button.backgroundColor = UIColor.green
                button.setTitleColor(UIColor.white, for: .normal)
                button.setTitle("SAVE CHANGES", for: .normal)
                button.titleLabel?.textAlignment = .center
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
                button.addTarget(self, action: #selector(ISSViewAReminderViewController.saveChanges(sender:)), for: .touchUpInside)
                
                cell?.contentView.addSubview(button)
                
                return cell!
            }
            
        case 3: // Next ISS Viewing OR save button (if there's no placemark
            
            var cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")
            
            if cell == nil
            {
                cell = UITableViewCell(style: .subtitle, reuseIdentifier: "basicCell")
                cell?.selectionStyle = .none
            }
            
            let arrivalTimeObject = (self.newReminder?.arrivalTimes?[indexPath.item])!
            cell?.textLabel?.text = arrivalTimeObject.riseTime.humanReadableDate
            cell?.detailTextLabel?.text = "Duration: \(arrivalTimeObject.duration!) seconds"
            
            return cell!

        case 4: // Save changes
        
            var cell = tableView.dequeueReusableCell(withIdentifier: "basicCellButton")
            
            if cell == nil
            {
                cell = UITableViewCell(style: .default, reuseIdentifier: "basicCellButton")
                cell?.selectionStyle = .none
            }
            if let subviews = cell?.contentView.subviews // make sure that nothing funky's going on with how Apple preserves views
            {
                for aSubview in subviews
                {
                    aSubview.removeFromSuperview()
                }
            }
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height:44))
            
            button.backgroundColor = UIColor.green
            button.setTitleColor(UIColor.white, for: .normal)
            button.setTitle("SAVE CHANGES", for: .normal)
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
            button.addTarget(self, action: #selector(ISSViewAReminderViewController.saveChanges(sender:)), for: .touchUpInside)
            
            cell?.contentView.addSubview(button)
            
            return cell!
            
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell")
            return cell!
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titles = ["Name", "Address", "Map", "Next ISS viewing", ""]
        
        if(section == 2 && self.tempPlacemark == nil)
        {
            return ""
        }
        
        return titles[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 && (self.tempPlacemark != nil || self.newReminder?.arrivalTimes != nil)
        {
            return 240.0
        }
        
        return self.tableView.rowHeight
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
        if textField == nameTextField
        {
            self.newReminder?.name = textField.text
        }
        
        if textField == addressTextField, textField.text!.characters.count > 0
        {
            // query for a location here
            
            let address = textField.text!
            
            self.forwardGeocode(inputAddress: address, completed: { (success, error, aPlacemark) in
                
                if(success)
                {
                    DispatchQueue.main.async
                        {
                            self.tempPlacemark = aPlacemark
                    }
                    // Is our data fresh?
                    
                    if let arrivalTimes = self.newReminder?.arrivalTimes
                    {
                        if(Date().minutes(from: arrivalTimes[0].riseTime) > 1)// if our data's older than a minute, it most likely won't be accurate
                        {
                            self.newReminder?.refreshArrivalTimes(completed: { (success, error) in
                                
                                if(success)
                                {
                                    DispatchQueue.main.async
                                        {
                                            self.tableView.reloadData()
                                    }
                                }
                            })
                        }
                    }
                    else
                    {
                        self.newReminder?.refreshArrivalTimes(completed: { (success, error) in
                            
                            if(success)
                            {
                                DispatchQueue.main.async
                                    {
                                        self.tableView.reloadData()
                                }
                            }
                        })
                    }
                }
                else
                {
                    // handle error here
                }
            })
        }
    }
}

extension ISSViewAReminderViewController:MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    {
        if(self.tempPlacemark != nil)
        {
           return (self.tempPlacemark?.location?.coordinate)!
        }
        else{
            return (self.newReminder?.location.coordinate)!
        }
        
    }
}
