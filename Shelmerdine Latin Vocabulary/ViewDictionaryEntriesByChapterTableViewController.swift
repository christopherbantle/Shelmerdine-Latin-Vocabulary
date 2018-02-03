//
//  ViewDictionaryEntriesByChapterTableViewController.swift
//  Shelmerdine Latin Vocabulary
//
//  Created by Christopher Bantle on 2018-02-02.
//  Copyright © 2018 Christopher Bantle. All rights reserved.
//

import UIKit

class ViewDictionaryEntriesByChapterTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    
    private var categories: [WordType]!
    
    private var dictionaryEntries: [[DictionaryEntry]]!
    
    // MARK: Setup
    
    func loadData() {
        let data = databaseManager.getDictionaryEntries(for: chapterForIndividualChapterViewScreen)
        categories = data.categories
        dictionaryEntries = data.dictionaryEntries
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Chapter " + chapterForIndividualChapterViewScreen.rawValue.description
        
        loadData()
        
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 51
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: Table view delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return dictionaryEntries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dictionaryEntries[section].count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section].rawValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChapterViewDictionaryEntryCell", for: indexPath) as! DictionaryEntryTableViewCell
        let dictionaryEntry = dictionaryEntries[indexPath.section][indexPath.row]
        cell.wordsLabel.text = dictionaryEntry.words
        cell.definitionLabel.text = dictionaryEntry.definition
        return cell
    }
    
    // MARK: Picker delegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 32
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "Chapter " + (row + 1).description
    }
    
    // MARK: Actions
    
    @IBAction func handleBookButtonPress(_ sender: Any) {
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 250,height: 250)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(self.chapterForIndividualChapterViewScreen.rawValue - 1, inComponent: 0, animated: false)
        viewController.view.addSubview(pickerView)
        
        let selectChapterAlert = UIAlertController(title: "Select Chapter", message: "", preferredStyle: UIAlertControllerStyle.alert)
        selectChapterAlert.setValue(viewController, forKey: "contentViewController")
        
        let doneSelectingAction = UIAlertAction(title: "Done", style: .default, handler: {(action) in
            if self.chapterForIndividualChapterViewScreen.rawValue != (pickerView.selectedRow(inComponent: 0) + 1) {
                self.chapterForIndividualChapterViewScreen = Chapter(rawValue: pickerView.selectedRow(inComponent: 0) + 1)!
                self.navigationItem.title = "Chapter " + self.chapterForIndividualChapterViewScreen.rawValue.description
                self.loadData()
                self.tableView.reloadData()
            }
            selectChapterAlert.dismiss(animated: true, completion: nil)
        })
        selectChapterAlert.addAction(doneSelectingAction)
        self.present(selectChapterAlert, animated: true, completion: nil)
    }
}
