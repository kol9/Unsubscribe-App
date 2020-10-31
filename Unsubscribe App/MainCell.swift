//
//  MainCell.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 31.10.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit

class MainCell: UITableViewCell {
    
    
    var onReuse: () -> Void = {}
    
    
    var onTap: () -> Void = {}
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        groupLogo.image = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        groupLogo.backgroundColor = .red
        groupNameLabel.text = "YOYOYO"
        // Initialization code
    }
    @IBAction func buttonTapped(_ sender: Any) {
        onTap()
    }
    
    @IBOutlet weak var groupLogo: UIImageView!
    @IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var groupConsLabel: UILabel!
    

}
