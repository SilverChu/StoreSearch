//
//  ViewController.swift
//  StoreSearch
//
//  Created by Silver Chu on 2017/7/4.
//  Copyright © 2017年 Silver Chu. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    let search = Search()
    
    var landscapeViewController: LandscapeViewController?
    
    weak var splitViewDetail: DetailViewController?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        performSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0) // 下移整个TableView64px
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80 // 初始化table view的行高
        
        if UIDevice.current.userInterfaceIdiom != .pad {
            searchBar.becomeFirstResponder() // 默认打开APP就在搜索栏并弹出软键盘
        }
        
        title = NSLocalizedString("Search", comment: "Split-view master button")
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified: // iPad上认为横屏竖屏均为.regular的情况
            hideLandscape(with: coordinator)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            if case .results(let list) = search.state {
                let detailViewController = segue.destination as! DetailViewController
                let indexPath = sender as! IndexPath
                let searchResult = list[indexPath.row]
                
                detailViewController.searchResult = searchResult
                detailViewController.isPopup = true
            }
        }
    }
    
    /*
    func performStoreRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8) // 以UTF-8的形式解析URL
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }
    */
    
    func showNetworkError() {
        let alert = UIAlertController(title: NSLocalizedString("Whoops...", comment: "Error alert: title"), message: NSLocalizedString("There was an error reading from the iTunes Store. Please try again.", comment: "Error alert: message"), preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeViewController == nil else {
            return
        }
        
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder() // 如果keyboard存在则移除
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.didMove(toParentViewController: self)
            })
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: {_ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            })
        }
    }
    
    func hideMasterPane() {
        UIView.animate(withDuration: 0.25, animations: {
            self.splitViewController!.preferredDisplayMode = .primaryHidden
        }, completion: { _ in
            self.splitViewController!.preferredDisplayMode = .automatic
        })
    }

}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    /*
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder() // 告诉搜索栏不再监听keyboard，直到再次点击
            dataTask?.cancel()
            
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let url = iTunesURL(searchText: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
            let session = URLSession.shared
            // 收到server端回复时调用completionHandler中方法
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                print("On main thread? " + (Thread.current.isMainThread ? "Yes" : "No"))
                
                if let error = error as NSError?, error.code == -999 {
                    return
                } else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data, let jsonDictionary = self.parse(json: data) {
                        self.searchResults = self.parse(dictionary: jsonDictionary)
                        self.searchResults.sort(by: <)
                        
                        DispatchQueue.main.async {
                            print("On main thread? " + (Thread.current.isMainThread ? "Yes" : "No"))
                            
                            self.isLoading = false
                            self.tableView.reloadData() // main thread渲染UI
                        }
                        
                        return //跳出当前方法体
                    }
                } else {
                    print("Failure! \(response!)")
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            
            dataTask?.resume()
        }
    }
    */
 
    func performSearch() {
        if let category = Search.Category(rawValue: segmentedControl.selectedSegmentIndex) {
            search.performSearch(for: searchBar.text!, category: category, completion: { success in
                if !success {
                    self.showNetworkError()
                }
                self.tableView.reloadData()
                self.landscapeViewController?.searchResultsReceived()
            })
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached // 将搜索栏的背景色沿用至状态栏
    }
    
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .notSearchedYet:
            return 0
        case .loading:
            return 1
        case .noResults:
            return 1
        case .results(let list):
            return list.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch search.state {
        case .notSearchedYet:
            fatalError("Should never get here")
        case .loading:
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            
            spinner.startAnimating()
            
            return cell
        case .noResults:
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        case .results(let list):
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            let searchResult = list[indexPath.row]
            
            cell.configure(for: searchResult)
            
            return cell
        }
    }
    
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        if view.window!.rootViewController!.traitCollection.horizontalSizeClass == .compact {
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: "ShowDetail", sender: indexPath)
        } else {
            if case .results(let list) = search.state {
                if splitViewController!.displayMode != .allVisible {
                    hideMasterPane()
                }
                
                splitViewDetail?.searchResult = list[indexPath.row]
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        switch search.state {
        case .notSearchedYet, .loading, .noResults:
            return nil
        case .results:
            return indexPath
        }
    }
}
