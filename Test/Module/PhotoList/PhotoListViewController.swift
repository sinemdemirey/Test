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
    
    var isLoaded = false
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        initVM()
        initTableView()
    }
    
    //MARK: — initView Methode
    func initView() {
        self.navigationItem.title = "Recent Photos"
        photoTableView.estimatedRowHeight = 150
        photoTableView.rowHeight = UITableView.automaticDimension
    }
    
    //MARK: — initViewModel Methode
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
    
    //MARK: — initTableView Methode
    func initTableView(){
        let loadingCell = UINib(nibName: "SpinnerTableViewCell", bundle: nil)
        photoTableView.register(loadingCell, forCellReuseIdentifier: "loadingCell")
    }
    
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: — TableView Extensions
extension PhotoListViewController : UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return viewModel.numberOfCells
        }else if section == 1{
            return 1
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            guard let cell = photoTableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as? PhotoListTableViewCell else {
                fatalError("Cell not exists in storyboard.")
            }
            let cellVM = viewModel.getCellViewModel( at: indexPath )
            cell.photoListCellViewModel = cellVM
            return cell
        } else {
            let cell = photoTableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! SpinnerTableViewCell
            cell.spinner.startAnimating()
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 150.0
        } else {
            return 50.0
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if (offsetY > contentHeight - scrollView.frame.height * 4) && !viewModel.isLoading {
            //loadMoreData()
        }
    }
    
    func loadMoreData(){
        if !viewModel.isLoading {
//            viewModel.isLoading = true
            DispatchQueue.global().async {
                sleep(2)
                DispatchQueue.main.async {
                    self.photoTableView.reloadData()
                    self.viewModel.isLoading = false
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastElement = viewModel.numberOfCells - 1
        if indexPath.row == lastElement {
            if !self.isLoaded {
               // viewModel.initFetch()
            }
        }
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

//MARK: — TableViewCell 
class PhotoListTableViewCell : UITableViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photoListCellViewModel : PhotoListCellViewModel? {
        didSet{
            guard let imageURL = URL(string: photoListCellViewModel!.imageUrl) else { return }
            DispatchQueue.global().async {
                guard let imageData = try? Data(contentsOf: imageURL) else { return }
                DispatchQueue.main.async {
                    self.photoImageView.image = UIImage(data: imageData)
                }
            }
        }
    }
}

