//
//  Extension.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 30.10.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//

import Foundation

import UIKit

var vSpinner : UIView?

extension UIViewController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView(frame: onView.bounds)
        spinnerView.layer.cornerRadius = onView.layer.cornerRadius
        spinnerView.backgroundColor = UIColor.systemBackground
        
        let ai = UIActivityIndicatorView.init(style: .medium)
        ai.color = .systemGray
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            print("Showing spinner")
            spinnerView.addSubview(ai)
            self.view.isUserInteractionEnabled = false
            onView.addSubview(spinnerView)
        }
        
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            
            print("Removed spinner")
            self.view.isUserInteractionEnabled = true
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}
