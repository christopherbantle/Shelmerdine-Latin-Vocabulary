//
//  ViewDictionaryEntriesByCategoryTableViewController.swift
//  Shelmerdine Latin Vocabulary
//
//  Created by Christopher Bantle on 2018-02-02.
//  Copyright © 2018 Christopher Bantle. All rights reserved.
//

import UIKit

class ViewDictionaryEntriesCumulativelyTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    
    private var latestChapter = Chapter.ChapterOne
    
    private var isInSearchMode: Bool {
        get{
            return self.searchController.isActive
        }
    }
    
    private var searchType: SearchType?
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var filteredDictionaryEntries: [[DictionaryEntry]]!
    
    private var dictionaryEntries: [[DictionaryEntry]]!
    
    private var filteredCategories: [WordType]!
    
    private var categories: [WordType]!
    
    // MARK: Setup
    
    func loadData() {
        if self.isInSearchMode {
            let data = self.databaseManager.getDictionaryEntries(forChaptersUpToAndIncluding: self.latestChapter, containing: self.searchController.searchBar.text!, searchType: self.searchType!)
            self.filteredDictionaryEntries = data.dictionaryEntries
            self.filteredCategories = data.categories
        } else {
            let data = self.databaseManager.getDictionaryEntries(forChaptersUpToAndIncluding: self.latestChapter)
            self.dictionaryEntries = data.dictionaryEntries
            self.categories = data.categories
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchBar.keyboardType = .asciiCapable
        self.navigationItem.searchController = self.searchController
        self.definesPresentationContext = true
        self.searchController.searchBar.scopeButtonTitles = ["By Word", "By Definition"]
        self.searchController.searchBar.delegate = self
        
        self.navigationItem.title = "Vocabulary"
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        // Get the latest chapter and category from the app delegate
        
        self.loadData()
        
        tableView.estimatedRowHeight = 49
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: Table view delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.isInSearchMode {
            return self.filteredDictionaryEntries.count
        } else {
            return self.dictionaryEntries.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.isInSearchMode {
            return self.filteredDictionaryEntries[section].count
        } else {
            return self.dictionaryEntries[section].count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.isInSearchMode {
            return self.filteredCategories[section].rawValue
        } else {
            return self.categories[section].rawValue
        }
    }
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isInSearchMode {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CumulativeViewDictionaryEntryCell", for: indexPath) as! CumulativeViewDictionaryEntryTableViewCell
            let dictionaryEntry = self.filteredDictionaryEntries[indexPath.section][indexPath.row]
            cell.wordsLabel.text = dictionaryEntry.words
            cell.definitionLabel.text = dictionaryEntry.definition
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CumulativeViewDictionaryEntryCell", for: indexPath) as! CumulativeViewDictionaryEntryTableViewCell
            let dictionaryEntry = self.dictionaryEntries[indexPath.section][indexPath.row]
            cell.wordsLabel.text = dictionaryEntry.words
            cell.definitionLabel.text = dictionaryEntry.definition
            return cell
        }
     }
    
    // MARK: Search controller delegate
    
    func updateSearchResults(for searchController: UISearchController) {
        self.tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if selectedScope == 0 {
            self.searchType = .ByWord
        } else {
            self.searchType = .ByDefinition
        }
        self.tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.tableView.reloadData()
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
    
    @IBAction func handleSearchButtonPress(_ sender: Any) {
        self.searchController.isActive = true
    }
    
    @IBAction func handleBookButtonPress(_ sender: Any) {
        let viewController = UIViewController()
        viewController.preferredContentSize = CGSize(width: 250,height: 300)
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 0, width: 250, height: 300))
        pickerView.delegate = self
        pickerView.dataSource = self
        viewController.view.addSubview(pickerView)
        
        let selectChapterAlert = UIAlertController(title: "Select Chapter", message: "", preferredStyle: UIAlertControllerStyle.alert)
        selectChapterAlert.setValue(viewController, forKey: "contentViewController")
        
        let doneSelectingAction = UIAlertAction(title: "Done", style: .default, handler: {(action) in
            if self.latestChapter.rawValue != (pickerView.selectedRow(inComponent: 0) + 1) {
                self.latestChapter = Chapter(rawValue: pickerView.selectedRow(inComponent: 0) + 1)!
                self.loadData()
                self.tableView.reloadData()
            }
            selectChapterAlert.dismiss(animated: true, completion: nil)
        })
        selectChapterAlert.addAction(doneSelectingAction)
        self.present(selectChapterAlert, animated: true, completion: nil)
    }
}
