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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as UICollectionViewCell
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
            if let _cell=cell as? NoteCell {
                if let _label = _cell.titleLabel{
                    _label.text = object.valueForKey("name")?.description
                }
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
                label.text = detail.valueForKey("timeStamp")!.description
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
        //self.tagCollectionView.registerClass(NoteCell.self, forCellWithReuseIdentifier: "cvCell")
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
    
    @IBAction func addNewTag(){
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        let context = appDelegate.managedObjectContext!
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Tags", inManagedObjectContext: context) as NSManagedObject
        newManagedObject.setValue(newTagTextField.text, forKey: "name")
        let _tags = self.detailItem?.mutableSetValueForKey("tags")
        _tags?.addObject(newManagedObject)
        
        var error: NSError? = nil
        if !context.save(&error) {
            abort()
        }
        newTagTextField.text=""
        
        self.configureView()
    }
    
    

}

