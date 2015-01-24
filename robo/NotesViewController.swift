//
//  NotesViewController.swift
//  robo
//
//  Created by kin dai on 15/1/24.
//  Copyright (c) 2015年 YUAN LIN. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NotesViewController: UICollectionViewController {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var tag:NSManagedObject? {
        didSet{
            notes = (tag?.valueForKey("notes") as NSSet).allObjects as NSArray
            configureView()
        }
    }
    
    var notes:NSArray?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        
        //        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        //        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewObject() -> NSManagedObject {
        let context = self.managedObjectContext
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Notes", inManagedObjectContext: context!) as NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
        let _tags = newManagedObject.valueForKey("tags")
        _tags?.addObject(tag!)
        
//        // Save the context.
//        var error: NSError? = nil
//        if !(self.managedObjectContext?.save(&error) != nil) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            //println("Unresolved error \(error), \(error.userInfo)")
//            abort()
//        }
        return newManagedObject
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.collectionView.indexPathsForSelectedItems()?[0]{
                let object = self.notes?[indexPath.row] as NSManagedObject
                (segue.destinationViewController as DetailViewController).detailItem = object
            }
        }
        if segue.identifier == "newNote" {
            let newNote = insertNewObject()
            (segue.destinationViewController as DetailViewController).detailItem = newNote
        }
    }
    
    // MARK: - Table View
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return notes?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as NoteCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let _cell = cell as NoteCell
        let object = notes?[indexPath.row] as NSManagedObject
        _cell.titleLabel.text = object.valueForKey("digest")!.description
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        self.collectionView.reloadData()
    }
    
    
}

