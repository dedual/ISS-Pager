//
//  ViewController.swift
//  ISS Pager
//
//  Created by Nicolas Dedual on 12/21/16.
//  Copyright © 2016 Dedual Enterprises Inc. All rights reserved.
//

import UIKit

class MainContainerViewController: UIViewController {
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    private lazy var mapViewController: ISSMapViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ISSMapViewController") as! ISSMapViewController
        viewController.referenceContainerViewController = self
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    private lazy var remindersViewController: ISSRemindersViewController = {
        // Load Storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        // Instantiate View Controller
        var viewController = storyboard.instantiateViewController(withIdentifier: "ISSRemindersViewController") as! ISSRemindersViewController
        
        viewController.referenceContainerViewController = self
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: viewController)
        
        return viewController
    }()
    
    lazy var reminders:[ISSReminder] =
    {
        var allReminders:[ISSReminder] = []
        
        if let savedItems = UserDefaults.standard.array(forKey: kSavedItemsKey)
        {
            for savedItem in savedItems
            {
                if let reminder = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? ISSReminder
                {
                    allReminders.append(reminder)
                    
                    reminder.refreshArrivalTimes(completed: { (success, error) in
                        
                    })
                }
            }
        }
        
        return allReminders
    }()
    
    // MARK: - View Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        let addRemindersButton:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(MainContainerViewController.addReminder(_:)))
        
        self.navigationItem.rightBarButtonItem = addRemindersButton
        
        // update reminders here
        
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        refreshAllReminders()
    }
    
    func refreshAllReminders()
    {
        var allReminders:[ISSReminder] = []
        
        if let savedItems = UserDefaults.standard.array(forKey: kSavedItemsKey)
        {
            for savedItem in savedItems
            {
                if let reminder = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? ISSReminder
                {
                    allReminders.append(reminder)
                    
                    reminder.refreshArrivalTimes(completed: { (success, error) in
                        
                    })
                }
            }
        }
        
        self.reminders = allReminders
    }
    
    private func setupView() {
        setupSegmentedControl()
        
        updateView()
    }
    
    private func updateView() {
        if segmentedControl.selectedSegmentIndex == 0 {
            remove(asChildViewController: remindersViewController)
            add(asChildViewController: mapViewController)
        } else {
            remove(asChildViewController: mapViewController)
            add(asChildViewController: remindersViewController)
        }
        
    }
    
    private func setupSegmentedControl() {
        // Configure Segmented Control
        segmentedControl.removeAllSegments()
        segmentedControl.insertSegment(withTitle: "Map", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "Saved", at: 1, animated: false)
        segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
        
        // Select First Segment
        segmentedControl.selectedSegmentIndex = 0
    }
    
    // MARK: - Actions
    func selectionDidChange(_ sender: UISegmentedControl) {
        updateView()
    }
    
    // MARK: - Helper Methods
    private func add(asChildViewController viewController: UIViewController) {
        // Add Child View Controller
        // addChildViewController(viewController)
        // Add Child View as Subview
        view.addSubview(viewController.view)
        
        // Configure Child View
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        // viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        // Notify Child View Controller
        viewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        viewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        viewController.removeFromParentViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addReminder(_ sender:UIButton)
    {
        // save current reminders state
        
        let items = NSMutableArray()
        for aReminder in reminders {
            let item = NSKeyedArchiver.archivedData(withRootObject: aReminder)
            items.add(item)
        }
        
        UserDefaults.standard.set(items, forKey: kSavedItemsKey)
        UserDefaults.standard.synchronize()
        
        let popViewController = ISSViewAReminderViewController()
        let navigationController = UINavigationController(rootViewController: popViewController)
        
        self.present(navigationController, animated: true) { 
            
        }
        
    }

}

