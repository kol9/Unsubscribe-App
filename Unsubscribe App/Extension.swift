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
    func showSpinner(onView : UIView, _ clr: UIColor = .systemBackground) {
        let spinnerView = UIView(frame: onView.bounds)
        spinnerView.layer.cornerRadius = onView.layer.cornerRadius
        spinnerView.backgroundColor = clr
        
        let ai = UIActivityIndicatorView.init(style: .medium)
        ai.color = .systemGray
        ai.startAnimating()
        ai.center = spinnerView.center
        
        let label = UILabel()
        
        label.text = "Отписываемся..."
        label.textAlignment = .center
//        label.textColor =
        label.center = CGPoint(x: spinnerView.center.x, y: spinnerView.center.y + 20)
        
        label.frame = CGRect(x: spinnerView.center.x - 100, y: spinnerView.center.y + 30, width: 200, height: 30)
        DispatchQueue.main.async {
            print("Showing spinner")
            spinnerView.addSubview(ai)
            spinnerView.addSubview(label)
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
