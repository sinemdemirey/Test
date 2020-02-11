//
//  SpinnerTableViewCell.swift
//  Test
//
//  Created by Sinem Demirey on 6.02.2020.
//  Copyright © 2020 Sinem Demirey. All rights reserved.
//

import UIKit

class SpinnerTableViewCell: UITableViewCell {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
