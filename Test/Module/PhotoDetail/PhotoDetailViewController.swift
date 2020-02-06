//
//  PhotoDetailViewController.swift
//  Test
//
//  Created by Sinem Demirey on 4.02.2020.
//  Copyright © 2020 Sinem Demirey. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var detailImageView: UIImageView!
    
    var imageUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: imageUrl!)
        let data = try? Data(contentsOf: url!)
        detailImageView.image = UIImage(data: data!)
        
    }
    

}
