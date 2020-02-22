//
//  ViewController.swift
//  pushe-xcode-sample
//
//  Created by Hector on 2/20/20.
//  Copyright © 2020 pushe. All rights reserved.
//

import UIKit
import Pushe

class ViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var actionsTableView: UITableView!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var actionsTableViewHeight: NSLayoutConstraint!
    
    let rowHeight: CGFloat = 60
    let sectionHeaderHeight: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        if let pusheVersion = self.getPusheVersionFromREADME() {
            self.versionLabel.text = "version \(pusheVersion)"
        } else {
            self.versionLabel.text = nil
        }
        
        self.configureActionsTableView()
    }
    
    private func getPusheVersionFromREADME() -> String? {
        guard let url = Bundle.main.url(forResource: "README", withExtension: "md"),
              let contents = try? String(contentsOf: url) else {
            return nil
        }
        
        let array = contents.split { (char) -> Bool in
            return char == " " || char == "\n" || char == ":"
        }

        guard let index = array.firstIndex(of: "sdk-version"),
              array.count > index + 1 else {
            return nil
        }
        
        return String(array[index + 1])
    }
    
    private func configureActionsTableView() {
        self.actionsTableView.register(UINib(nibName: "ActionTableViewCell", bundle: nil), forCellReuseIdentifier: "ActionTableViewCell")
        self.actionsTableView.delegate = self
        self.actionsTableView.dataSource = self
        
        let cellsHeight = CGFloat(Action.allCases.count) * (self.rowHeight + self.sectionHeaderHeight) + self.sectionHeaderHeight
        let maxHeightForTableView = self.view.bounds.height * 0.65
        self.actionsTableViewHeight.constant = min(cellsHeight, maxHeightForTableView)
    }
    
    private func logToConsole(registrationStatus: Bool) {
        var result = "\n----------\n"
        result += "Device registered: \(registrationStatus)\n"
        result += self.getTimeStamp()
        self.consoleTextView.text.append(result)
    }
    
    private func logToconsole(topicName: String?, subscribe: Bool, errorMessage: String?) {
        var result = "\n----------\n"
        if subscribe {
            result += "subscribe to topic:"
        } else {
            result += "unsubscribe from topic:"
        }
        
        if let topicName = topicName {
            result += "\(topicName)"
        }
        result += "\n"
        
        if let errorMessage = errorMessage {
            result += "error:\(errorMessage)"
        } else {
            result += "done"
        }
        result += "\n"
        
        result += self.getTimeStamp()
        self.consoleTextView.text.append(result)
    }
    
    private func logToConsole(input: String?, add: Bool, errorMessage: String?) {
        var result = "\n----------\n"
        if add {
            result += "add tags:"
        } else {
            result += "remove tags:"
        }
        result += "\n"
        
        if let input = input {
            result += "\(input)\n"
        }
        
        if let errorMessage = errorMessage {
            result += "error:\(errorMessage)"
        } else {
            result += "done"
        }
        result += "\n"
        
        result += self.getTimeStamp()
        self.consoleTextView.text.append(result)
    }
    
    private func logToConsole(eventName: String?) {
        var result = "\n----------\n"
        
        if let eventName = eventName {
            result += "Event <\(eventName)> sent."
        } else {
          result += "no Event specified"
        }
        result += "\n"
        
        result += self.getTimeStamp()
        self.consoleTextView.text.append(result)
    }
    
    private func clearLogs() {
        self.consoleTextView.text = "Click an action to test it."
    }
    
    private func getTimeStamp() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm:ss"
        return dateFormatter.string(from: Date())
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ActionTableViewCell,
              let action = cell.action else {
            tableView.cellForRow(at: indexPath)?.isSelected = false
            return
        }
        
        switch action {
        case .ids:
            var result = String()
            if let deviceId = PusheClient.shared.getDeviceId() {
                result += "DeviceId:\n"
                result += "\(deviceId)\n----------\n"
            }
            
            /*if*/ let advertisingId = PusheClient.shared.getAdvertisingId() //{
                result += "AdvertisingId:\n"
                result += "\(advertisingId)"
            //}
            
            let alertController = UIAlertController(title: "IDs", message: result, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alertController, animated: true) {
                cell.isSelected = false
            }
        case .deviceRegistrationStatus:
            self.logToConsole(registrationStatus: PusheClient.shared.isRegistered())
            cell.isSelected = false
        case .topic:
            var result = String()
            result += "Topics: \(PusheClient.shared.getSubscribedTopics())\n"
            result += "Enter topic name to subscribe or unsubscribe"
            let alertController = UIAlertController(title: "Topic", message: result, preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "topic name"
            }
            
            alertController.addAction(UIAlertAction(title: "SUBSCRIBE", style: .default, handler: { (_) in
                guard let topicName = alertController.textFields?[0].text,
                      !topicName.isEmpty else {
                    self.logToconsole(topicName: nil, subscribe: true, errorMessage: "no topic name specified")
                    return
                }
                
                PusheClient.shared.subscribe(to: topicName) { (error) in
                    self.logToconsole(topicName: topicName, subscribe: true, errorMessage: error?.localizedDescription)
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "UNSUBSCRIBE", style: .default, handler: { (_) in
                guard let topicName = alertController.textFields?[0].text,
                      !topicName.isEmpty else {
                    self.logToconsole(topicName: nil, subscribe: false, errorMessage: "no topic name specified")
                    return
                }
                
                PusheClient.shared.unsubscribe(from: topicName) { (error) in
                    self.logToconsole(topicName: topicName, subscribe: false, errorMessage: error?.localizedDescription)
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true) {
                cell.isSelected = false
            }
        case .tag:
            var result = String()
            result += "Tags: \(PusheClient.shared.getSubscribedTags())\n"
            result += "Tag in {name:value, ...} format (add)\n"
            result += "Tag in [name, ...] format (remove)"
            let alertController = UIAlertController(title: "Tags", message: result, preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "{\"key1\": \"value1\", ...}or[\"key1\", ...]"
            }
            
            alertController.addAction(UIAlertAction(title: "ADD", style: .default, handler: { (_) in
                guard let input = alertController.textFields?[0].text,
                      !input.isEmpty else {
                    self.logToConsole(input: nil, add: true, errorMessage: "no input")
                    return
                }
                
                if let data = input.data(using: .utf8),
                   let dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                    PusheClient.shared.addTags(with: dictionary)
                    self.logToConsole(input: input, add: true, errorMessage: nil)
                } else {
                    self.logToConsole(input: input, add: true, errorMessage: "input is malformed")
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "REMOVE", style: .default, handler: { (_) in
                guard let input = alertController.textFields?[0].text,
                      !input.isEmpty else {
                    self.logToConsole(input: nil, add: false, errorMessage: "no input")
                    return
                }
                
                if let data = input.data(using: .utf8),
                    let array = try? JSONSerialization.jsonObject(with: data, options: []) as? [String] {
                    PusheClient.shared.removeTags(with: array)
                    self.logToConsole(input: input, add: false, errorMessage: nil)
                } else {
                    self.logToConsole(input: input, add: false, errorMessage: "input is malformed")
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alertController, animated: true) {
                cell.isSelected = false
            }
        case .event:
            let alertController = UIAlertController(title: "Event", message: "Type event name to send", preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "event's name"
            }
            
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                guard let eventName = alertController.textFields?[0].text,
                      !eventName.isEmpty else {
                    self.logToConsole(eventName: nil)
                    return
                }
                
                PusheClient.shared.sendEvent(with: eventName)
                self.logToConsole(eventName: eventName)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alertController, animated: true) {
                cell.isSelected = false
            }
        case .clear:
            self.clearLogs()
            cell.isSelected = false
        }
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return Action.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionTableViewCell", for: indexPath) as? ActionTableViewCell,
            indexPath.section < Action.allCases.count else {
            return UITableViewCell()
        }
        
        cell.action = Action.allCases[indexPath.section]
        return cell
    }
}

