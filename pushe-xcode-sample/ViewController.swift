//
//  ViewController.swift
//  pushe-xcode-sample
//
//  Created by Hector on 2/20/20.
//  Copyright © 2020 pushe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var actionsTableView: UITableView!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var actionsTableViewHeight: NSLayoutConstraint!
    
    let rowHeight: CGFloat = 60
    let sectionHeaderHeight: CGFloat = 8
    let actions = ["IDs",
                   "Device registration status",
                   "Topic",
                   "Tag(name:value)",
                   "Event"]
    
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
        
        let cellsHeight = CGFloat(self.actions.count) * (self.rowHeight + self.sectionHeaderHeight) + self.sectionHeaderHeight
        let maxHeightForTableView = self.view.bounds.height * 0.65
        self.actionsTableViewHeight.constant = min(cellsHeight, maxHeightForTableView)
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
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.actions.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActionTableViewCell", for: indexPath) as? ActionTableViewCell,
              indexPath.section < self.actions.count else {
            return UITableViewCell()
        }
        
        cell.title = self.actions[indexPath.section]
        return cell
    }
}

