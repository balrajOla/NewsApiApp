//
//  HomePageViewController.swift
//  NewsApi
//
//  Created by Balraj Singh on 12/01/19.
//  Copyright © 2019 balraj. All rights reserved.
//

import UIKit
import PromiseKit
import SVProgressHUD

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var searchUsecase = NewsApiUsecase()
    private var isDataLoading:Bool = false
    private var lastSearchKeyword: String = ""
    
    var dataSource: NewsApiResponse?
    
    init() {
        super.init(nibName: String.stringFromClass(HomePageViewController.self), bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.searchUsecase.register(forPreExecution: { SVProgressHUD.show() }, forCompletion: handleResponseResult) 
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        self.tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ArticleTableViewCell")
        
        self.searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleResponseResult(_ values: (keyword: String, result: Result<NewsApiResponse>)) {
        guard let currentText = self.searchBar.text else {
            return
        }
        
        // hide progress view
        SVProgressHUD.dismiss()
        
        if currentText == values.keyword {
            // update datasource
            switch values.result {
            case .fulfilled(let res):
                self.dataSource = res
                self.tableView.reloadData()
            default: break
            }
        }
    }
}

// MARK: tableView Delegate & DataSource
extension HomePageViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.articles?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let myCell = tableView.dequeueReusableCell(withIdentifier: "ArticleTableViewCell", for: indexPath as IndexPath) as! ArticleTableViewCell
        
        // get data based on index
        if let articleData = self.dataSource,
            let article = articleData.articles?[indexPath.row] {
            myCell.setUpData(for: article)
        }
        
        return myCell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        isDataLoading = false
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print("scrollViewDidEndDecelerating")
    }
    
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        print("scrollViewDidEndDragging")
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height)
        {
            if !isDataLoading{
                isDataLoading = true
                self.searchUsecase.performSearch(for: self.lastSearchKeyword)
            }
        }
    }
}

// MARK: Search Delegate
extension HomePageViewController: UISearchBarDelegate {
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.lastSearchKeyword = searchText
        self.searchUsecase.performSearch(for: self.lastSearchKeyword)
    }
}

