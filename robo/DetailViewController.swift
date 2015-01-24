//
//  DetailViewController.swift
//  robo
//
//  Created by kin dai on 15/1/11.
//  Copyright (c) 2015年 YUAN LIN. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController, UICollectionViewDataSource{

    @IBOutlet weak var detailDescriptionLabel: UITextView!
    @IBOutlet weak var detailTimestampLabel: UILabel!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var newTagTextField: UITextField!
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var tags: NSSet!
    
    let reuseIdentifier = "cvCell"
    
//    override init(){
//        super.init()
//    }
//
//    required init(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
////        fatalError("init(coder:) has not been implemented")
//    }
    
    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            tags = detailItem?.valueForKey("tags") as NSSet
            self.configureView()
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        if let _tags = tags{
            return _tags.count
        }
        return 0
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as TagCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int{
        return 1
    }
    
    func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        if let _tags = self.tags {
            let tagArray = _tags.allObjects as NSArray
            let object = tagArray[indexPath.row]
            if let _cell=cell as? TagCell {
                _cell.dataObject = object as NSManagedObject
//                _cell.removeBtn.tag = indexPath.row
            }
        }
        
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                label.text = detail.valueForKey("digest")!.description
            }
            if let label = self.detailTimestampLabel {
                let formatter = NSDateFormatter()
                formatter.dateFormat = "MM-dd HH:mm"
                label.text = formatter.stringFromDate(detail.valueForKey("timeStamp") as NSDate)
            }
            if let tagColView = self.tagCollectionView{
                tagColView.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let completeBtn = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "detailEndEditing:")
        self.navigationItem.rightBarButtonItem = completeBtn
        
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        
        if self.detailItem==nil{
            self.detailItem=newObject()
        }
        //self.tagCollectionView.registerClass(TagCell.self, forCellWithReuseIdentifier: "cvCell")
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func newObject() -> NSManagedObject{
        let context = self.managedObjectContext
        let entity = NSEntityDescription.entityForName("Notes", inManagedObjectContext: self.managedObjectContext!) as NSEntityDescription?
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName((entity?.name)!, inManagedObjectContext: context!) as NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue("", forKey: "digest")
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
        
        return newManagedObject
    }

    func detailEndEditing(sender: UITextView){
        
        if let detail: AnyObject = self.detailItem {
            if let label = self.detailDescriptionLabel {
                detail.setValue(label.text, forKey: "digest")
                detail.setValue(NSDate(), forKey: "timeStamp")
                
                var error: NSError?
                if !(self.managedObjectContext?.save(&error) != nil) {
                    println("Could not save \(error), \(error?.userInfo)")
                }
            }
        }
        
        
        if let preViewController = self.navigationController?.popViewControllerAnimated(true){
            return
        }
        
        self.performSegueWithIdentifier("showMaster", sender: self)
    }   
    
    @IBAction func addNewTag(){
        let context = self.managedObjectContext!
        let request = NSFetchRequest()
        let tagEntity = NSEntityDescription.entityForName("Tags", inManagedObjectContext: context)
        request.entity = NSEntityDescription.entityForName("Tags", inManagedObjectContext: context)
        
        request.predicate = NSPredicate(format: "name = %@", newTagTextField.text!)
        
        var error: NSError? = nil
        if let mutableFetchResults = context.executeFetchRequest(request, error: &error) {
            //non-existing
            var targetTag:NSManagedObject
            if mutableFetchResults.count==0 {
                targetTag = NSEntityDescription.insertNewObjectForEntityForName("Tags", inManagedObjectContext: context) as NSManagedObject
                targetTag.setValue(newTagTextField.text, forKey: "name")
            } else {// existing
                if mutableFetchResults.count>1 {
                    abort()
                }
                targetTag = mutableFetchResults.first? as NSManagedObject
            }
            let _tags = self.detailItem?.mutableSetValueForKey("tags")
            _tags?.addObject(targetTag)
        }
        
        if !context.save(&error) {
            abort()
        }
        newTagTextField.text=""
        
        self.configureView()
    }
    
    @IBAction func delTag(sender:AnyObject){
        let cell = (sender.superview as UIView?)?.superview as TagCell
        let _tags = self.detailItem?.mutableSetValueForKey("tags")
        _tags?.removeObject(cell.dataObject!)
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error) {
            abort()
        }

        self.configureView()
    }
    

}

