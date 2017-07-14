//
//  RelevantContentViewController.swift
//  Vanilla
//
//  Created by Alex on 7/11/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import FlybitsKernelSDK

class TextOnlyCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
}

class ImageOnlyCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
}

class MixedCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
}

class NoDataCell: UITableViewCell {
    @IBOutlet weak var noDataLabel: UILabel!
}

class RelevantContentTableViewController: UITableViewController {
    
    var pagedContent: Paged<Content>?
    
    // Define template IDs so that they're more usable in code
    enum TemplateID: String {
        case textOnly = "14A1899F-E190-47BD-A32F-8D96684245C9"  // text only
        case imageOnly = "C044C930-74FE-4FEF-A58C-9E340B56F1FE" // image only
        case mixed = "B7F47E8B-AC1D-4E9C-92C3-CF77D71E0183"     // mixed text and image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Context", style: .plain, target: self, action: #selector(RelevantContentTableViewController.showContextMenu))
        
        if relevantTimer == nil {
            DispatchQueue.main.async {
                self.relevantTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(RelevantContentTableViewController.loadAllRelevantData), userInfo: nil, repeats: true)
            }
            loadAllRelevantData()
        }
    }
    
    var relevantTimer: Timer?
    func loadAllRelevantData() {
        // Associate template IDs with their data models
        let templateIDsAndAssociatedClassesDictionary: [String: ContentData.Type] = [
            TemplateID.textOnly.rawValue: TextOnlyContent.self,
            TemplateID.imageOnly.rawValue: ImageOnlyContent.self,
            TemplateID.mixed.rawValue: MixedContent.self
        ]
        
        // Set limit to max, therefore no paging will occur. This is unsuggested but this is
        //let pager = Pager(limit: UInt.max, offset: 0, countRecords: nil, sortBy: nil, sortOrder: nil)
        _ = Content.getAllRelevant(with: templateIDsAndAssociatedClassesDictionary, pager: nil) { pagedContent, error in
            defer {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            guard let pagedContent = pagedContent, error == nil else {
                print("Returned without any relevant content.")
                return
            }
            self.pagedContent = pagedContent
        }
    }
    
    func showContextMenu() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContextMenu")
        DispatchQueue.main.async {
            self.navigationController?.show(vc, sender: self)
        }
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pagedContent = pagedContent else {
            return 1
        }
        return pagedContent.elements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pagedContent = pagedContent else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataCell", for: indexPath) as! NoDataCell
            cell.noDataLabel?.text = "No Data"
            return cell
        }
        let contentInstance = pagedContent.elements[indexPath.row]
        switch contentInstance.templateId! {
        case TemplateID.textOnly.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextOnlyCell", for: indexPath) as! TextOnlyCell
            guard let contentData = contentInstance.pagedContentData?.elements.first as? TextOnlyContent else {
                return cell
            }
            cell.nameLabel?.text = contentData.textTitle.value!
            cell.descriptionLabel?.text = contentData.textDescription.value!
            return cell
        case TemplateID.imageOnly.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageOnlyCell", for: indexPath) as! ImageOnlyCell
            guard let contentData = contentInstance.pagedContentData?.elements.first as? ImageOnlyContent else {
                return cell
            }
            
            var components = URLComponents(string: contentData.imageURL.absoluteString)!
            if components.scheme == nil {
                components.scheme = "http"
            }
            let urlRequest = URLRequest(url: components.url!)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let request = session.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                cell.imgView.image = UIImage(data: data)
            }
            request.resume()
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MixedCell", for: indexPath) as! MixedCell
            guard let contentData = contentInstance.pagedContentData?.elements.first as? MixedContent else {
                return cell
            }
            cell.nameLabel?.text = contentData.textTitle.value!
            cell.descriptionLabel?.text = contentData.textDescription.value!
            var components = URLComponents(string: contentData.imageURL.absoluteString)!
            if components.scheme == nil {
                components.scheme = "http"
            }
            let urlRequest = URLRequest(url: components.url!)
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let request = session.dataTask(with: urlRequest) { data, response, error in
                guard let data = data, error == nil else {
                    return
                }
                cell.imgView.image = UIImage(data: data)
            }
            request.resume()
            return cell
        }
    }
}
