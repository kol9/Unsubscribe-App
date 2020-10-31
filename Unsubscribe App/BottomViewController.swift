//
//  BottomViewController.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 30.10.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import UIKit

class BottomViewController: UIViewController {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var lastPostLabel: UILabel!
    
    @IBOutlet weak var unsubscribeButton: UIButton!
    var closeClosure: (()->Void) = {}
    
    @IBOutlet weak var closeButton: UIButton!
    
    
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        closeClosure()
    }
    
    @IBAction func openButtonTapped(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    

}
