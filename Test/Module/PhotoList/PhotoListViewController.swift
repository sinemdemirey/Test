//
//  ViewController.swift
//  Test
//
//  Created by Sinem Demirey on 3.02.2020.
//  Copyright © 2020 Sinem Demirey. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PhotoListViewController: UIViewController {

    @IBOutlet weak var photoTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var viewModel: PhotoListViewModel = {
        return PhotoListViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initVM()
        
    }
    
    func initView() {
        self.navigationItem.title = "Recent Photos"
        photoTableView.estimatedRowHeight = 150
        photoTableView.rowHeight = UITableView.automaticDimension
    }
    
    func initVM() {
        
        // Naive binding
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.photoTableView.alpha = 0.0
                    })
                }else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.photoTableView.alpha = 1.0
                    })
                }
            }
        }
        
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.photoTableView.reloadData()
            }
        }
        
        viewModel.initFetch()

    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

extension PhotoListViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = photoTableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoListTableViewCell else {
            fatalError("Cell not exists in storyboard.")
        }
        
        let cellVM = viewModel.getCellViewModel( at: indexPath )
        cell.photoListCellViewModel = cellVM
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(identifier: "PhotoDetailViewController") as? PhotoDetailViewController
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.viewModel.userPressed(at: indexPath)
        if viewModel.isAllowSegue {
            return indexPath
        }else {
            return nil
        }
    }
    
}

extension PhotoListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? PhotoDetailViewController,
            let photo = viewModel.selectedPhoto {
            vc.imageUrl = photo.image_url
        }
    }
}

class PhotoListTableViewCell : UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photoListCellViewModel : PhotoListCellViewModel? {
        didSet{
            let url = URL(string: photoListCellViewModel!.imageUrl)
            let data = try? Data(contentsOf: url!)
            photoImageView.image = UIImage(data: data!)
        }
    }
}

