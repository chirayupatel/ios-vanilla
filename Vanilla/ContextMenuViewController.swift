//
//  ContextMenuViewController.swift
//  Vanilla
//
//  Created by Alex on 7/13/17.
//  Copyright © 2017 Alex. All rights reserved.
//

import UIKit
import FlybitsContextSDK

class MenuCell: UITableViewCell {
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}

class ContextMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items = [
        ["Add Custom Context Data"],
        
        // Contexts
        ["Send 'Student'","Send 'High-Net'","Send 'Pensioner'"],
        ["Send Balance: 1000","Send Balance: 10000"],
        ["Send Credit Card: VISA","Send Credit Card: Mastercard"]
    ]
    // Edit this? Edit effect tableView(_:didSelectRowAt:)
    let context = BankingDataContextPlugin(accountBalance: 0, segmentation: "", creditCard: "")

    @IBOutlet weak var tableView: UITableView!
    weak var userLogInDelegate: UserLogInDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView(frame: .zero)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ContextMenuViewController.close))
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section(rawValue: section)!
        return items[section.rawValue].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        let section = Section(rawValue: indexPath.section)!
        cell.nameLabel?.text = items[section.rawValue][indexPath.row]
        cell.imgView?.image = UIImage(named: "ic_launcher")
        
        return cell
    }
    
    func receivedUpdate(_ data: Any?, error: Any?) {
        if data != nil {
            print("Received data: \(String(describing: data))")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let section = Section(rawValue: indexPath.section)!
        
        switch section {
        case .standard:
            // TODO: Add custom context data
            break
        case .contextSegmentationUpdates:
            switch indexPath.row {
            case 0:
                context.segmentation = "Student"
            case 1:
                context.segmentation = "High-Net"
            default:
                context.segmentation = "Pensioner"
            }
        case .contextBalanceUpdates:
            switch indexPath.row {
            case 0:
                context.accountBalance = 1000
            default:
                context.accountBalance = 10000
            }
        case .contextCreditCardUpdates:
            switch indexPath.row {
            case 0:
                context.creditCard = "VISA"
            default:
                context.creditCard = "Mastercard"
            }
        }
        context.refreshData(completion: receivedUpdate)
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    enum Section: Int {
        case standard, contextSegmentationUpdates, contextBalanceUpdates, contextCreditCardUpdates
        static var count: Int { return Section.contextCreditCardUpdates.hashValue + 1}
    }
}
