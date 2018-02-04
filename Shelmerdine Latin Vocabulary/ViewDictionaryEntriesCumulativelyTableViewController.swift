//
//  ViewDictionaryEntriesByCategoryTableViewController.swift
//  Shelmerdine Latin Vocabulary
//
//  Created by Christopher Bantle on 2018-02-02.
//  Copyright © 2018 Christopher Bantle. All rights reserved.
//

import UIKit

class ViewDictionaryEntriesCumulativelyTableViewController: UITableViewController, UISearchBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    
    private var isInSearchMode = false
    
    private var searchType: SearchType = .ByWord
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var filteredDictionaryEntries: [[DictionaryEntry]]!
    
    private var dictionaryEntries: [[DictionaryEntry]]!
    
    private var filteredCategories: [WordType]!
    
    private var categories: [WordType]!
    
    // MARK: Setup
    
    func loadData() {
        if self.isInSearchMode {
            let data = databaseManager.getDictionaryEntries(forChaptersUpToAndIncluding: latestChapterForCumulativeViewScreen, containing: searchController.searchBar.text!, searchType: searchType)
            filteredDictionaryEntries = data.dictionaryEntries
            filteredCategories = data.categories
        } else {
            let data = databaseManager.getDictionaryEntries(forChaptersUpToAndIncluding: latestChapterForCumulativeViewScreen)
            dictionaryEntries = data.dictionaryEntries
            categories = data.categories
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.keyboardType = .asciiCapable
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["By Word", "By Definition"]
        searchController.searchBar.delegate = self
        
        loadData()
        
        tableView.allowsSelection = false
        tableView.estimatedRowHeight = 51
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: Table view delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        if isInSearchMode {
            return filteredDictionaryEntries.count
        } else {
            return dictionaryEntries.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isInSearchMode {
            return filteredDictionaryEntries[section].count
        } else {
            return dictionaryEntries[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isInSearchMode {
            return filteredCategories[section].rawValue
        } else {
            return categories[section].rawValue
        }
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isInSearchMode {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CumulativeViewDictionaryEntryCell", for: indexPath) as! DictionaryEntryTableViewCell
            let dictionaryEntry = filteredDictionaryEntries[indexPath.section][indexPath.row]
            cell.wordsLabel.text = dictionaryEntry.words
            cell.definitionLabel.text = dictionaryEntry.definition
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CumulativeViewDictionaryEntryCell", for: indexPath) as! DictionaryEntryTableViewCell
            let dictionaryEntry = dictionaryEntries[indexPath.section][indexPath.row]
            cell.wordsLabel.text = dictionaryEntry.words
            cell.definitionLabel.text = dictionaryEntry.definition
            return cell
        }
     }
    
    // MARK: Search controller delegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        loadData()
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            searchType = .ByWord
        } else {
            searchType = .ByDefinition
        }
        loadData()
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isInSearchMode = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isInSearchMode = false
        tableView.reloadData()
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
        pickerView.selectRow(self.latestChapterForCumulativeViewScreen.rawValue - 1, inComponent: 0, animated: false)
        viewController.view.addSubview(pickerView)
        
        let selectChapterAlert = UIAlertController(title: "Select Chapter", message: "", preferredStyle: UIAlertControllerStyle.alert)
        selectChapterAlert.setValue(viewController, forKey: "contentViewController")
        
        let doneSelectingAction = UIAlertAction(title: "Done", style: .default, handler: {(action) in
            if self.latestChapterForCumulativeViewScreen.rawValue != (pickerView.selectedRow(inComponent: 0) + 1) {
                self.latestChapterForCumulativeViewScreen = Chapter(rawValue: pickerView.selectedRow(inComponent: 0) + 1)!
                self.loadData()
                self.tableView.reloadData()
            }
            selectChapterAlert.dismiss(animated: true, completion: nil)
        })
        selectChapterAlert.addAction(doneSelectingAction)
        self.present(selectChapterAlert, animated: true, completion: nil)
    }
}
