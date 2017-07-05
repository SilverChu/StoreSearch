//
//  ViewController.swift
//  StoreSearch
//
//  Created by Silver Chu on 2017/7/4.
//  Copyright © 2017年 Silver Chu. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    var searchResults: [SearchResult] = []
    var hasSearched = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    struct TableViewCellIdentifier {
        static let searchResultCell = "SearchResultCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0) // 下移整个TableView64px
        
        let cellNib = UINib(nibName: TableViewCellIdentifier.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifier.searchResultCell)
        
        tableView.rowHeight = 80
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // 告诉搜索栏不再监听keyboard，直到再次点击
        
        searchResults = []
        if searchBar.text! != "justin bieber" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fate result %d for", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        
        hasSearched = true
        tableView.reloadData()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached // 将搜索栏的背景色沿用至状态栏
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }else if searchResults.count == 0 {
            return 1
        } else {
            return searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifier.searchResultCell, for: indexPath) as! SearchResultCell
        
        if searchResults.count == 0 {
            cell.nameLabel.text = "(Nothing found)"
            cell.artistNameLabel.text = ""
        } else {
            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            cell.artistNameLabel!.text = searchResult.artistName
        }
        
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}
