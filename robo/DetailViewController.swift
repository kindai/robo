//
//  DetailViewController.swift
//  robo
//
//  Created by kin dai on 15/1/11.
//  Copyright (c) 2015年 YUAN LIN. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController{

    @IBOutlet weak var detailDescriptionLabel: UITextView!
    @IBOutlet weak var detailTimestampLabel: UILabel!
    

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("digest")!.description
            }
            if let labelTs = self.detailTimestampLabel {
                labelTs.text = detail.valueForKey("timeStamp")!.description
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let completeBtn = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "detailEndEditing:")
        self.navigationItem.rightBarButtonItem = completeBtn
        
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func detailEndEditing(sender: UITextView){
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                self.detailItem?.setValue(label.text, forKey: "digest")
                self.detailItem?.setValue(NSDate(), forKey: "timeStamp")
            }
        }
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }

}

