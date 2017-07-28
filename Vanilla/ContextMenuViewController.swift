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

class CustomContextViewController: UIViewController {
    
    @IBOutlet weak var textField: UITextField!
    weak var contextPlugin: ContextPlugin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Custom Context"
        textField.text = (contextPlugin as? BankingDataContextPlugin)?.segmentation ?? ""
    }
    
    @IBAction func setContext(sender: Any?) {
        (contextPlugin as! BankingDataContextPlugin).segmentation = textField?.text ?? ""
        navigationController?.topViewController?.dismiss(animated: true) {
            self.navigationController?.topViewController?.dismiss(animated: true, completion: nil)
        }
    }
}

class ContextMenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var items = [
        ["Add Custom Context Data"],
        ["Send 'Student'","Send 'High-Net'","Send 'Pensioner'"],
        ["Send Balance: 1000","Send Balance: 10000"],
        ["Send Credit Card: VISA","Send Credit Card: Mastercard"]
    ]
    
    @IBOutlet weak var tableView: UITableView!
    var contextPlugin: BankingDataContextPlugin!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(ContextMenuViewController.close))
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func close() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return [nil, "Segmentation", "Account Balance", "Credit Card"][section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = Section(rawValue: section)!
        return items[section.rawValue].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
        
        let section = Section(rawValue: indexPath.section)!
        let text = items[section.rawValue][indexPath.row]
        cell.nameLabel?.text = text
        if let selected = tableView.indexPathForSelectedRow, selected == indexPath {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
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
        case .customContext:
            
            let customConextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomContext") as! CustomContextViewController
            customConextVC.contextPlugin = contextPlugin
            DispatchQueue.main.async {
                self.show(customConextVC, sender: self)
            }
            
        case .contextSegmentationUpdates:
            switch indexPath.row {
            case 0:
                contextPlugin.segmentation = "Student"
            case 1:
                contextPlugin.segmentation = "High-Net"
            default:
                contextPlugin.segmentation = "Pensioner"
            }
        case .contextBalanceUpdates:
            switch indexPath.row {
            case 0:
                contextPlugin.accountBalance = 1000
            default:
                contextPlugin.accountBalance = 10000
            }
        case .contextCreditCardUpdates:
            switch indexPath.row {
            case 0:
                contextPlugin.creditCard = "VISA"
            default:
                contextPlugin.creditCard = "Mastercard"
            }
        }
        
        let contextData = contextPlugin.toDictionary()
        
        _ = ContextDataRequest.sendData([contextData]) { (error) -> () in
            guard error == nil else {
                print("Error sending context data: \(error!.localizedDescription)")
                return
            }
            print("Successfully uploaded context data")
        }.execute()
        
        if section != .customContext {
            DispatchQueue.main.async {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    enum Section: Int {
        case customContext, contextSegmentationUpdates, contextBalanceUpdates, contextCreditCardUpdates
        static var count: Int { return Section.contextCreditCardUpdates.hashValue + 1}
    }
}
