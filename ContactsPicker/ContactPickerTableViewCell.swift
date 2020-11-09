//
//  ContactPickerTableViewCell.swift
//  ContactsPicker
//
//  Created by Idan Moshe on 07/11/2020.
//

import UIKit
import Contacts

class ContactPickerTableViewCell: UITableViewCell {
    
    static let identifier: String = "ContactPickerTableViewCell"
    
    @IBOutlet private weak var topLabel: UILabel!
    @IBOutlet private weak var bottomLabel: UILabel!
    @IBOutlet private weak var contactImageView: UIImageView!
    @IBOutlet private weak var contactInitialsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contactImageView.layer.cornerRadius = self.contactImageView.frame.size.width/2
        self.contactImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(contact: CNContact) {
        self.topLabel.text = "\(contact.givenName) \(contact.familyName)"
        self.bottomLabel.text = contact.phoneNumbers[0].value.stringValue
        
        if let imageData: Data = contact.imageData, let image = UIImage(data: imageData) {
            self.contactImageView.backgroundColor = .clear
            self.contactImageView.image = image
        } else {
            self.contactImageView.backgroundColor = .lightGray
        }
        
        var initials: String = ""
        if let first: Character = contact.givenName.first {
            initials += String(first)
        }
        if let second: Character = contact.familyName.first {
            initials += String(second)
        }
        
        self.contactInitialsLabel.text = initials
    }
    
}
