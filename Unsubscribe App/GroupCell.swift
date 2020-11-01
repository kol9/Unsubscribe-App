//
//  GroupCell.swift
//  Unsubscribe App
//
//  Created by Nikolay Yarlychenko on 01.03.2020.
//  Copyright © 2020 Nikolay Yarlychenko. All rights reserved.
//


import UIKit



class GroupCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    var _isPicked = false
    
    var isPicked: Bool {
        set (newVal) {
            _isPicked = newVal
            if newVal {
                checkerView.isHidden = false
                selectView.isHidden = false
            } else {
                checkerView.isHidden = true
                selectView.isHidden = true
            }
        }
        
        get {
            return _isPicked
        }
    }
    
    var onReuse: () -> Void = {}
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        addSubview(imageView)
        addSubview(labelView)
        addSubview(selectView)
        addSubview(checkerView)
        
        checkerView.isHidden = true
        selectView.isHidden = true
        isPicked = false
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
        imageView.image = nil
        isPicked = false
    }
    
    var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .systemGray3
        view.clipsToBounds = true
        return view
    }()
    
    
    var labelView: UILabel = {
        let view = UILabel()
        
        view.numberOfLines = 3
        view.font = UIFont(name: "SFProDisplay-Regular", size: 14)
//        view.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.2
        view.textAlignment = .center
        view.text = "Департамент сутулых собак"
        return view
    }()
    
    func setTitle(_ s: String) {
        labelView.text = s
    }
    
    
    

    
    var selectView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .clear
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 63.0 / 255.0, green: 138.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0).cgColor
        
        return view
    }()
    
    
    var checkerView: UIImageView = {
        let view = UIImageView()
        
        view.backgroundColor = UIColor(red: 63.0 / 255.0, green: 138.0 / 255.0, blue: 224.0 / 255.0, alpha: 1.0)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.image = #imageLiteral(resourceName: "check")
        view.tintColor = .white
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let numberOfItemsPerRow:CGFloat = 3
        let spacingBetweenCells:CGFloat = 16
        
        let totalSpacing = (2 * 16) + ((numberOfItemsPerRow - 1) * spacingBetweenCells) //Amount of total spacing in a row
        
        
        let width = (UIScreen.main.bounds.width - totalSpacing) / numberOfItemsPerRow
        let height = CGFloat(158)
        
        imageView.frame = CGRect(x: 0, y: 0, width: width, height: width)
        imageView.layer.cornerRadius = width / 2
        
        
        let w2 = width + 10
        selectView.frame = CGRect(x: -5, y: -5, width: w2, height: w2)
        selectView.layer.cornerRadius = w2 / 2
        
        let h = width / 4
        
        
        checkerView.frame = CGRect(x: width - 25, y: width - 30, width: h, height: h)
        checkerView.layer.cornerRadius = 14.5
        
        labelView.frame = CGRect(x: 0, y: 114, width: width, height: 36)
    }
    
    
}
