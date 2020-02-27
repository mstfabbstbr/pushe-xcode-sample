//
//  ActionTableViewCell.swift
//  pushe-xcode-sample
//
//  Created by Hector on 2/20/20.
//  Copyright © 2020 pushe. All rights reserved.
//

import UIKit

class ActionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var action: Action? {
        didSet {
            self.titleLabel.text = self.action?.rawValue
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.white
        self.layer.shadowPath = CGPath(rect: self.layer.bounds, transform: nil)
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 3
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
