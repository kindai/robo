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

class NotesViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    var tag:AnyObject? {
        didSet{
            configureView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext!
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewNote:")
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func insertNewNote(sender: UIBarButtonItem){
        self.performSegueWithIdentifier("newNote", sender: self)
    }
    
    func insertNewObject() -> NSManagedObject {
        let context = self.managedObjectContext
        let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName("Notes", inManagedObjectContext: context!) as NSManagedObject
        
        // If appropriate, configure the new managed object.
        // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
        newManagedObject.setValue(NSDate(), forKey: "timeStamp")
        newManagedObject.setValue("", forKey: "digest")
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
                let object = self.fetchedResultsController.objectAtIndexPath(indexPath as NSIndexPath) as NSManagedObject
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
        return self.fetchedResultsController.sections?.count ?? 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as NoteCell
        self.configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
        let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
        (cell as NoteCell).dataObject = object
    }
    
    var fetchedResultsController: NSFetchedResultsController {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest = NSFetchRequest()
        // Edit the entity name as appropriate.
        let entity = NSEntityDescription.entityForName("Notes", inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.entity = entity
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: false)
        let sortDescriptors = [sortDescriptor]
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "ANY tags.name = %@", tag?.valueForKey("name") as String)
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        var error: NSError? = nil
        if !_fetchedResultsController!.performFetch(&error) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //println("Unresolved error \(error), \(error.userInfo)")
            abort()
        }
        
        return _fetchedResultsController!
    }
    var _fetchedResultsController: NSFetchedResultsController? = nil
    
//    func controllerWillChangeContent(controller: NSFetchedResultsController) {
//        self.collectionView.reloadData()
//    }
    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//        case .Insert:
//            self.collectionView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        case .Delete:
//            self.collectionView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        default:
//            return
//        }
//    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            collectionView.insertItemsAtIndexPaths([newIndexPath!])
        case .Delete:
            collectionView.deleteItemsAtIndexPaths([indexPath!])
        case .Update:
            self.configureCell(collectionView.cellForItemAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
        case .Move:
            collectionView.performBatchUpdates({ () -> Void in
                self.collectionView.deleteItemsAtIndexPaths([indexPath!])
                self.collectionView.insertItemsAtIndexPaths([newIndexPath!])
            }, completion: nil)
            
        default:
            return
        }
    }
    
//    func controllerDidChangeContent(controller: NSFetchedResultsController) {
//        self.collectionView.endUpdates()
//    }

    
    func configureView() {
        // Update the user interface for the detail item.
        self.collectionView.reloadData()
    }
    
    @IBAction func delNote(sender:AnyObject){
        let cell = (sender.superview as UIView?)?.superview as NoteCell
        self.managedObjectContext?.deleteObject(cell.dataObject!)
        var error: NSError? = nil
        if !self.managedObjectContext!.save(&error) {
            abort()
        }
        
        self.configureView()
    }
    
    
}

