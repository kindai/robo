//
//  NoteCell.swift
//  robo
//
//  Created by kin dai on 15/1/24.
//  Copyright (c) 2015年 YUAN LIN. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class NoteCell : UICollectionViewCell {
    
    var dataObject:NSManagedObject?{
        didSet{
            self.titleLabel.text = dataObject?.valueForKey("digest")?.description
        }
    };
    
    @IBOutlet weak var titleLabel:UILabel!;
    @IBOutlet weak var removeBtn:UIButton!;
    
}