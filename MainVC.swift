//
//  MainVC.swift
//  ScholarSync-Adam
//
//  Created by Adam on 8/19/24.
//

import Foundation
import UIKit

class MainVC: UIViewController, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
    
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var homeView: UIView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var favoritesTableView: UITableView!
    
    @IBOutlet weak var matchingScholarshipsTableView: UITableView!
    @IBOutlet weak var matchingScholarshipsView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchClearButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var noFavoritesDataLabel: UILabel!
    
    @IBOutlet weak var searchView: SearchView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var data: [Scholarship] = []
    var matchingData: [Scholarship] = []
    var favoritesData: [Scholarship] = []
    var selectedScholarship: Scholarship!
    var selectedIndex = 0
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var searchingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    let totalTime: TimeInterval = 3.0
        let updateInterval: TimeInterval = 0.2
        var elapsedTime: TimeInterval = 0.0
        var timer: Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = false
                
        searchView.setupUI()
        tabBar.selectedItem = tabBar.items?.first
        NotificationCenter.default.addObserver(self, selector: #selector(ScholarshipSuccessHandler(_:)), name: Notification.Name("ScholarshipSuccess"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(FindMatchingScholarshipsHandler(_:)), name: Notification.Name("FindMatchingScholarships"), object: nil)
        
        
        homeTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "homeTableViewCell")
        self.homeTableView.reloadData()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
        favoritesTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "favoritesTableViewCell")
        self.favoritesTableView.reloadData()
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        
        matchingScholarshipsTableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "matchingScholarshipsTableViewCell")
        self.matchingScholarshipsTableView.reloadData()
        matchingScholarshipsTableView.delegate = self
        matchingScholarshipsTableView.dataSource = self
        
        tabBar.delegate = self
        ScrapeService.shared.scrapeAll()
       
       
    }
    
    
    @IBAction func closeButton_tapHandler(_ sender: Any) {
        searchTextField.text = ""
        if selectedIndex == 0 {
            showAll()
            self.homeTableView.reloadData()
        } else if selectedIndex == 1 {
            showFavorites()
            self.favoritesTableView.reloadData()
        }
        view.endEditing(true)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
  
    
    @IBAction func infoButtonTapped(_ sender: Any) {
       let vc = AboutVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
            print ("Tab Bar Selected")
        if item.tag  == 1 {
            selectedIndex = 0
            showAll()
            homeView.isHidden = false
            favoritesView.isHidden = true
            infoView.isHidden = true
            matchingScholarshipsView.isHidden = true
            self.homeTableView.reloadData()
        } else if item.tag == 2 {
            selectedIndex = 1
            showFavorites()
            homeView.isHidden = true
            favoritesView.isHidden = false
            infoView.isHidden = true
            matchingScholarshipsView.isHidden = true
            self.favoritesTableView.reloadData()
        } else if item.tag == 3 {
            selectedIndex = 2
            homeView.isHidden = true
            favoritesView.isHidden = true
            infoView.isHidden = true
            matchingScholarshipsView.isHidden = false
        } else if item.tag == 4 {
            selectedIndex = 3
            homeView.isHidden = true
            favoritesView.isHidden = true
            infoView.isHidden = false
            matchingScholarshipsView.isHidden = true
//            matchingScholarshipsTableView.isHidden = true
        }
        
       
    }
    
    func showAll() {
        print ("Show ALl")
        data = ScrapeService.shared.getAll()
        self.homeTableView.reloadData()
    }
    
    func showFavorites() {
        print ("Show Favorites")
        favoritesData = ScrapeService.shared.getFavorites()
        if favoritesData.count == 0 {
            noFavoritesDataLabel.isHidden = false
        } else {
            noFavoritesDataLabel.isHidden = true
        }
        self.favoritesTableView.reloadData()
    }
    
    @objc func ScholarshipSuccessHandler(_ notification: Notification) {
        data = ScrapeService.shared.allScholarshipList
        print ("Total Length. \(data.count)")
        DispatchQueue.main.async {
            self.homeTableView.reloadData()
            self.favoritesTableView.reloadData()
            self.spinner.isHidden = true
        }
    }
    
    @objc func FindMatchingScholarshipsHandler(_ notification: Notification) {
//            let userInfo = notification.userInfo
                        
        progressView.isHidden = false
        searchingLabel.isHidden = false
        
        self.matchingScholarshipsTableView.isHidden = false
        timer?.invalidate()
                // Create a new timer
                timer = Timer.scheduledTimer(timeInterval: updateInterval, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        
    }
    
    @objc func updateProgress() {
        let selectedMonth = searchView.selectedMonth
        let selectedYear = searchView.selectedYear
        let selectedGrade = searchView.selectedGrade
        let selectedState = searchView.selectedState
        
           elapsedTime += updateInterval
           let progress = Float(elapsedTime / totalTime)
        progressView.progress = progress
           
       
           // Check if the progress reaches 100%
           if progress >= 1.0 {
               // Invalidate the timer when loading is complete
               timer?.invalidate()
               searchingLabel.isHidden = true
               progressView.isHidden = true
             
               DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                   self.elapsedTime = 0.0
                   self.progressView.progress = 0
                   self.progressView.isHidden = true
                   self.searchingLabel.isHidden = true
                   
                   self.matchingData = ScrapeService.shared.findMatchingScholarships(month: selectedMonth, year: selectedYear, grade: selectedGrade, state: selectedState)
                   self.matchingScholarshipsTableView.reloadData()
               }
           }
       }
    
    
    @IBAction func btnClickHandler(_ sender: Any) {
        let vc = SelectedScholarshipVC()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    @IBAction func searchScholarships_changeHandler(_ sender: UITextField) {
        let val = sender.text ?? ""
        if selectedIndex == 0 {
            data = ScrapeService.shared.searchScholarships(search: val)
            self.homeTableView.reloadData()
        } else if selectedIndex == 1 {
            favoritesData = ScrapeService.shared.searchScholarships(search: val)
            self.favoritesTableView.reloadData()
        }
        
    }

}


extension MainVC {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == homeTableView {
            return data.count
        } else if tableView == favoritesTableView {
            return favoritesData.count
        } else if tableView == matchingScholarshipsTableView {
            return matchingData.count
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("indexPath.row: \(indexPath.row), matchingData.count: \(matchingData.count)")
        var obj: Scholarship!
        var cell: TableViewCell!
        if tableView == homeTableView {
            obj = data[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "homeTableViewCell", for: indexPath) as? TableViewCell
        } else if tableView == favoritesTableView {
            obj = favoritesData[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "favoritesTableViewCell", for: indexPath) as? TableViewCell
        } else if tableView == matchingScholarshipsTableView {
            let ind = indexPath.row
            obj = matchingData[ind]
            cell = tableView.dequeueReusableCell(withIdentifier: "matchingScholarshipsTableViewCell", for: indexPath) as? TableViewCell
        } else {
            return UITableViewCell()
        }
      
        cell.data = obj
        cell.titleLabel.text = obj.title
        cell.amountLabel.text = obj.amount
        cell.deadlineLabel.text = obj.deadline
        cell.gradeLevelLabel.text = obj.tag
        
        cell.setFavorites()
        if ScrapeService.shared.isDateWithinNext45Days(dateString: obj.deadline) {
            cell.endingSoonButton.isHidden = false
        } else {
            cell.endingSoonButton.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var obj: Scholarship!
        if selectedIndex == 0 {
            obj = data[indexPath.row]
        } else if selectedIndex == 1 {
            obj = favoritesData[indexPath.row]
        } else if selectedIndex == 2 {
            obj = matchingData[indexPath.row]
        }
        selectedScholarship = obj
        
        let vc = SelectedScholarshipVC()
        vc.scholarship = obj
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
