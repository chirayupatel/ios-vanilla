//
//  RelevantContentViewController.swift
//  Vanilla
//
//  Created by Alex on 7/11/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import FlybitsKernelSDK
import FlybitsContextSDK

class TextOnlyCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var nameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
}

class ImageOnlyCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
}

class MixedCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionHeightConstraint: NSLayoutConstraint!
}

class NoDataCell: UITableViewCell {
    @IBOutlet weak var noDataLabel: UILabel!
}

class RelevantContentTableViewController: UITableViewController {
    
    var pagedContent: Paged<Content>?
    var contextPlugin: BankingDataContextPlugin?
    
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
        
        self.contextPlugin = BankingDataContextPlugin(accountBalance: 0, segmentation: "", creditCard: "")
        _ = try? ContextManager.shared.register(self.contextPlugin!)
        
        if relevantTimer == nil {
            DispatchQueue.main.async {
                self.relevantTimer = Timer(fireAt: Date(), interval: 7, target: self, selector: #selector(RelevantContentTableViewController.loadAllRelevantData), userInfo: nil, repeats: true)
                RunLoop.current.add(self.relevantTimer!, forMode: .defaultRunLoopMode)
            }
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
        
        // Set limit to max, therefore no paging will occur.
        let pager = Pager(limit: UInt(Int32.max), offset: 0, countRecords: nil, sortBy: nil, sortOrder: nil)
        _ = Content.getAllRelevant(with: templateIDsAndAssociatedClassesDictionary, pager: pager) { pagedContent, error in
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
        guard let contextPlugin = self.contextPlugin else {
            print("Error: You haven't instantiated a context plugin yet.")
            return
        }
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ContextMenu") as! ContextMenuViewController
        vc.contextPlugin = contextPlugin
        let nav = UINavigationController(rootViewController: vc)
        DispatchQueue.main.async {
            self.navigationController?.show(nav, sender: self)
        }
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pagedContent = pagedContent else {
            return 1
        }
        return pagedContent.elements.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let pagedContent = pagedContent, let templateId = pagedContent.elements[indexPath.row].templateId, let template = TemplateID(rawValue: templateId) else {
            return 56
        }
        let contentInstance = pagedContent.elements[indexPath.row]
        switch template {
        case .textOnly:
            guard let contentData = contentInstance.pagedContentData?.elements.first as? TextOnlyContent else {
                return 0
            }
            var height = contentData.textTitle.value!.heightWithConstrainedWidth(UIScreen.main.bounds.width - 10, for: UIFont.systemFont(ofSize: 17)) + 15
            height += contentData.textDescription.value!.heightWithConstrainedWidth(UIScreen.main.bounds.width - 10, for: UIFont.systemFont(ofSize: 17)) + 15
            return height + 8 * 3
        case .imageOnly:
            return 150
        case .mixed:
            guard let contentData = contentInstance.pagedContentData?.elements.first as? MixedContent else {
                return 0
            }
            var height = contentData.textTitle.value!.heightWithConstrainedWidth(UIScreen.main.bounds.width - 111, for: UIFont.systemFont(ofSize: 17)) + 15
            height += contentData.textDescription.value!.heightWithConstrainedWidth(UIScreen.main.bounds.width - 111, for: UIFont.systemFont(ofSize: 17)) + 15
            height += 8 * 3
            return height > 100 ? height : 100
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let pagedContent = pagedContent, let templateId = pagedContent.elements[indexPath.row].templateId, let template = TemplateID(rawValue: templateId) else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataCell", for: indexPath) as! NoDataCell
            cell.noDataLabel?.text = "No Data"
            return cell
        }
        let contentInstance = pagedContent.elements[indexPath.row]
        var cell: UITableViewCell
        
        switch template {
        case .textOnly:
            cell = tableView.dequeueReusableCell(withIdentifier: "TextOnlyCell", for: indexPath) as! TextOnlyCell
            guard let contentData = contentInstance.pagedContentData?.elements.first as? TextOnlyContent else {
                return cell
            }
            (cell as! TextOnlyCell).nameHeightConstraint.constant = contentData.textTitle.value!.heightWithConstrainedWidth(UIScreen.main.bounds.width - 10, for: UIFont.systemFont(ofSize: 17))
            (cell as! TextOnlyCell).nameLabel?.text = contentData.textTitle.value!
            
            (cell as! TextOnlyCell).descriptionHeightConstraint.constant = contentData.textDescription.value!.heightWithConstrainedWidth(UIScreen.main.bounds.width - 10, for: UIFont.systemFont(ofSize: 17))
            (cell as! TextOnlyCell).descriptionLabel?.text = contentData.textDescription.value!
            cell.updateConstraintsIfNeeded()
            return cell
            
        case .imageOnly:
            cell = tableView.dequeueReusableCell(withIdentifier: "ImageOnlyCell", for: indexPath) as! ImageOnlyCell
            guard let contentData = contentInstance.pagedContentData?.elements.first as? ImageOnlyContent else {
                return cell
            }
            (cell as! ImageOnlyCell).imgView.downloadImageFrom(url: contentData.imageURL, contentMode: .scaleAspectFill)
            return cell
            
        case .mixed:
            cell = tableView.dequeueReusableCell(withIdentifier: "MixedCell", for: indexPath) as! MixedCell
            guard let contentData = contentInstance.pagedContentData?.elements.first as? MixedContent else {
                return cell
            }
            (cell as! MixedCell).nameHeightConstraint.constant = contentData.textTitle.value!.heightWithConstrainedWidth(UIScreen.main.bounds.width - 111, for: UIFont.systemFont(ofSize: 17))
            (cell as! MixedCell).nameLabel?.text = contentData.textTitle.value!
            
            (cell as! MixedCell).descriptionHeightConstraint.constant = contentData.textDescription.value!.heightWithConstrainedWidth(UIScreen.main.bounds.width - 111, for: UIFont.systemFont(ofSize: 17))
            (cell as! MixedCell).descriptionLabel?.text = contentData.textDescription.value!
            
            (cell as! MixedCell).imgView.downloadImageFrom(url: contentData.imageURL, contentMode: .scaleAspectFill)
            cell.updateConstraintsIfNeeded()
            return cell
        }
    }
}

extension UIImageView {
    func downloadImageFrom(url: URL, contentMode: UIViewContentMode) {
        var components = URLComponents(string: url.absoluteString)!
        if components.scheme == nil {
            components.scheme = "http"
        }
        URLSession.shared.dataTask(with: components.url!) { data, response, error in
            DispatchQueue.main.async {
                self.contentMode = contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }.resume()
    }
}
