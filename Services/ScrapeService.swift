//
//  ScrapeService.swift
//  ScholarSync-Adam
//
//  Created by Adam on 8/19/24.
//

import Foundation
import SwiftSoup

class ScrapeService {
    static let shared = ScrapeService()
    
    var allScholarshipList: [Scholarship] = []
//    var filteredScholarshipList: [Scholarship] = []
    
    var isLoading = false
    
    var done1 = false
    var done2 = false
    var done3 = false
    var done4 = false
    
    /*
    func scrapeFastWeb(page: String) -> [String] {
        var results = [String]()
        let urlString = page
        if let url = URL(string: urlString),
           let html = try? String(contentsOf: url) {
            do {
                let document = try SwiftSoup.parse(html)
                let activeAwards = try document.select("a.active_award")
                var uniqueTitles = Set<String>()
                activeAwards.forEach { activeAward in
                    let awardTitle = try! activeAward.text()
                    uniqueTitles.insert(awardTitle)
                }

                for title in uniqueTitles {
                    let matchingAward = try document.select("a.active_award:contains(\(title))")
                    if let activeAward = matchingAward.first() {
                        let awardLink = try activeAward.attr("href")
                        if let awardAmount = try document.select("td.info").first() {
                            
                            let scholarship = Scholarship(title: title, description: "", amount: "\(try! awardAmount.text())", link: "https://fastweb.com\(awardLink)", deadline: "Not Available", tag: "", favorite: false)
                            allScholarshipList.append(scholarship)
//                           filteredScholarshipList.append(scholarship)
                          
                        }
                    }
                }
                done1 = true
            } catch {
                print("Error parsing HTML: \(error.localizedDescription)")
                done1 = true
            }
        } else {
            print("Error fetching HTML content.")
            done1 = true
        }

        return results
    }
     */
    
    func scrapeScholarshipsDotCom(page: String, completion: @escaping () -> Void) {
        let favAr = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? []
        
        fetchHTML(from: page) { html in
            guard let html = html else {
                completion()
                        print("Failed to fetch HTML")
                        return
                    }
                    
                    do {
                        let document = try SwiftSoup.parse(html)
                        let scholarships = try document.select("div.award-box")
                        
                        for scholarship in scholarships {
                            var title = try scholarship.select("h2").text()
                            title = self.splitText(str: title, delimiter: " This scholarship")
                            if title == "" {
                                continue
                            }
                            let description = try scholarship.select("p").text()
                            var amount = try scholarship.select("span:contains($)").text()
                            amount = self.removeDuplicate(amount)
                            if amount == "" {
                                amount = "Varies"
                            }
                            
                            var link = try scholarship.select("a").attr("href")
                            link = "https://scholarships.com\(link)"
                            var deadline = try scholarship.select("span:contains(2024)").text()
                            deadline = self.removeDuplicate(deadline)
                            
                           let fav = self.isFavorite(str: title, favAr: favAr)
                            let scholarship = Scholarship(title: title, description: description, amount: amount, link: link, deadline: deadline, tag: "Multiple", favorite: fav)
                            self.allScholarshipList.append(scholarship)
//                            self.filteredScholarshipList.append(scholarship)
                          
                        }
                        completion()
                        // Process the document as needed
                    } catch {
                        completion()
                        print("Error parsing HTML: \(error)")
                    }
        }
      
    }
    
    func getFavorites() -> [Scholarship] {
        let favAr = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? []
        
        var res: [Scholarship] = []
        for item in allScholarshipList {
            if isFavorite(str: item.title, favAr: favAr) {
                var newItem = item
                newItem.favorite = true
                res.append(newItem)
            }
        }
        res = sortByDates(res: res)
        return res
    }
    
    func getAll() -> [Scholarship] {
        let favAr = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? []
        
        var res: [Scholarship] = []
        for item in allScholarshipList {
            var newItem = item
            if isFavorite(str: item.title, favAr: favAr) {                
                newItem.favorite = true
            } else {
                newItem.favorite = false
            }
            res.append(newItem)
        }
        res = sortByDates(res: res)
        return res
    }
    
    func sortByDates(res: [Scholarship]) -> [Scholarship] {
        if res.count == 0 {
            return []
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let sortedScholarships = res.sorted { obj1, obj2 in
            var deadline1 = obj1.deadline
            if deadline1 == "" {
                deadline1 = "Dec 31, 2025"
            }
            var deadline2 = obj2.deadline
            if deadline2 == "" {
                deadline2 = "Dec 31, 2025"
            }
            guard let date1 = dateFormatter.date(from: deadline1),
                  let date2 = dateFormatter.date(from: deadline2) else {
                return false
            }
            return date1 < date2
        }
        return sortedScholarships
    }
    
    func updateFavorites(item: Scholarship) {
        var existingFavAr = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? []
        
        if item.favorite {
            if existingFavAr.contains(item.title) {
                return
            }
            existingFavAr.append(item.title)
        } else {
            existingFavAr = existingFavAr.filter { $0 != item.title }
        }
        
        UserDefaults.standard.setValue(existingFavAr, forKey: "favorites")
    }
    
    func isFavorite(str: String, favAr: [String]) -> Bool {
        if favAr.count == 0 {
            return false
        }
        for fav in favAr {
            if fav == str {
                return true
            }
        }
        return false
    }

    func fetchHTML(from urlString: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching HTML: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }
            
            completion(html)
        }
        
        task.resume()
    }
    
    func scrape360(page: String, completion: @escaping () -> Void) {
        let favAr = UserDefaults.standard.array(forKey: "favorites") as? [String] ?? []
        
        fetchHTML(from: page) { html in
            guard let html = html else {
                        print("Failed to fetch HTML")
                completion()
                        return
                    }
                    
                    do {
                        let document = try SwiftSoup.parse(html)
                        let scholarships = try document.select("div.re-scholarship-card")

                        for scholarship in scholarships {
                            var title = try scholarship.select("h4.re-verified_title a").text()
                            title = self.splitText(str: title, delimiter: " This scholarship")
                            if title == "" {
                                continue
                            }
                            var description = try scholarship.select("p").text()
                            description = self.removeStrings(str: description)
                            var amount = try scholarship.select("span:contains($)").text()
                            amount = self.removeDuplicate(amount)
                            if amount == "" {
                                amount = "Varies"
                            }
                            let link = try scholarship.select("a").attr("href")
                            var deadline = try scholarship.select("span:contains(2024)").text()
                            deadline = self.removeDuplicate(deadline)
                            
                            let gradeLevelList = try scholarship.select("div.re-scholarship-card-info span.re-scholarship-card-info-value")
                            
                            let gradeElem = gradeLevelList[gradeLevelList.count - 1]
                            var gradeLevel = try gradeElem.text()
                            gradeLevel = self.splitText(str: gradeLevel, delimiter: " &")
                            gradeLevel = self.splitText(str: gradeLevel, delimiter: " ,")
                            if gradeLevel == "" {
                                gradeLevel = "Multiple"
                            }
                            let fav = self.isFavorite(str: title, favAr: favAr)
                            let scholarship = Scholarship(title: String(title), description: description, amount: amount, link: link, deadline: deadline, tag: gradeLevel, favorite: fav)
                            self.allScholarshipList.append(scholarship)
//                            self.filteredScholarshipList.append(scholarship)
                         
                        }
                        completion()
                        // Process the document as needed
                    } catch {
                        completion()
                        print("Error parsing HTML: \(error)")
                    }
        }
      
    }
    
    func removeStrings(str: String) -> String {
        /*
        var output = str.replacingOccurrences(of: "Offered by Scholarships360", with: "")
        output = output.replacingOccurrences(of: "The Scholarships360 ", with: "")
        output = output.replacingOccurrences(of: "Show Less", with: "")
        output = output.replacingOccurrences(of: "Show More ", with: "\n\n")
         */
        
        let outputAr = str.components(separatedBy: "Show More ")
        var output = str
        if outputAr.count > 2 {
            output = outputAr[2]
        } else if outputAr.count > 1 {
            output = outputAr[1]
        }   else {
            output = outputAr[0]
        }
        output = output.replacingOccurrences(of: "Show Less", with: "")
        return output
//        return output
    }
        
    func splitText(str: String, delimiter: String)-> String {
        let textBeforeNewLine = str.components(separatedBy: delimiter).first ?? str
        return textBeforeNewLine
    }
    
    func removeDuplicate(_ input: String) -> String {
        // Split the string into components by space
        let components = input.components(separatedBy: " ")
        if components.count == 1 {
            return input
        }
        // Determine the midpoint
        let midIndex = components.count / 2
        
        // Get the first half and the second half
        let firstHalf = components.prefix(midIndex).joined(separator: " ")
        let secondHalf = components.suffix(midIndex).joined(separator: " ")
        
        // Check if the first half and second half are the same
        if firstHalf == secondHalf {
            return firstHalf
        }
        
        // If they are not the same, return the original string
        return input
    }
    
   

    func scrapeAll() {
        isLoading = true
        allScholarshipList = []
//        filteredScholarshipList = []
        scrapeScholarshipsDotCom(page: "https://www.scholarships.com/financial-aid/college-scholarships/scholarships-by-grade-level/high-school-scholarships/scholarships-for-high-school-seniors") {
            self.done1 = true
            self.checkAllDone()
        }
        scrapeScholarshipsDotCom(page: "https://www.scholarships.com/financial-aid/college-scholarships/scholarships-by-grade-level/high-school-scholarships/scholarships-for-high-school-juniors") {
            self.done2 = true
            self.checkAllDone()
        }
        
        scrape360(page: "https://scholarships360.org/scholarships/easy-scholarships-to-apply-for/") {
            self.done3 = true
            self.checkAllDone()
        }
        scrape360(page: "https://scholarships360.org/scholarships/no-essay-scholarships/") {
            self.done4 = true
            self.checkAllDone()
        }

        isLoading = false
    }
    
    
    func removeDuplicateScholarships() {
        var dict: [String: Scholarship] = [:]
        for sch in allScholarshipList {
            let str = "\(sch.title)__\(sch.amount)__\(sch.deadline)__\(sch.tag)"
            if dict.keys.contains(str) {
                continue
            }
            dict[str] = sch
        }
        
        var res: [Scholarship] = []
        for (key, val) in dict {
            res.append(val)
        }
        allScholarshipList = res
        allScholarshipList = getAll()
    }
    
    
    func checkAllDone()  {
        if done1 && done2 && done3 && done4 {
            print ("Got scholarships from all sources")
            removeDuplicateScholarships()
//            sortByDates(res: allScholarshipList)
            NotificationCenter.default.post(name: Notification.Name("ScholarshipSuccess"), object: nil, userInfo:nil)
        }
        
    }
    
    func searchScholarships(search: String) -> [Scholarship] {
        if search == "" {
            return allScholarshipList
     
        }
        
        return allScholarshipList.filter { $0.title.lowercased().contains(search.lowercased()) }
       /*
        filteredScholarshipList = allScholarshipList.filter { $0.title.lowercased().contains(search.lowercased()) }
        return filteredScholarshipList
        */
        
    }
    
    func findMatchingScholarships(month: String, year: String, grade: String, state: String) -> [Scholarship] {
        var filtered1 = allScholarshipList
        var monthYearString = "\(month) \(year)"
        
        if grade == "All Grades" {
            filtered1 = allScholarshipList
        } else {
            filtered1 = allScholarshipList.filter { $0.tag.lowercased().contains(grade.lowercased()) }
        }
        
        var filtered2 = filtered1
        if month == "" && year == "" {
            filtered2 = filtered1
        } else {
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM yyyy"
            
            guard let filterDate = dateFormatter.date(from: monthYearString) else {
                    return filtered2
                }
            
            let calendar = Calendar.current
                
                // Extract the month and year from the filter date
                let filterComponents = calendar.dateComponents([.month, .year], from: filterDate)
                
                // Filter scholarships where the deadline matches the filter month and year
                filtered2 = filtered1.filter { scholarship in
                    // Convert the scholarship deadline to a Date object
                    dateFormatter.dateFormat = "MMM d, yyyy" // Full date format
                    if let scholarshipDate = dateFormatter.date(from: scholarship.deadline) {
                        let scholarshipComponents = calendar.dateComponents([.month, .year], from: scholarshipDate)
                        return scholarshipComponents.month == filterComponents.month && scholarshipComponents.year == filterComponents.year
                    }
                    return false
                }
        }
       
        var filtered3 = filtered2
        if state == "All States" {
            return filtered3
        } else {
            filtered3 = filtered2.filter { $0.description.lowercased().contains(state.lowercased()) }
            if filtered3.count == 0 {
                let randomIndices = Set<Int>(filtered2.indices.shuffled().prefix(3))
                    
                    // Retrieve the elements at the random indices
                    let randomElements = randomIndices.map { filtered2[$0] }
                    return randomElements
            } else {
               return filtered3
            }
        }
      
    }
    
    func isDateWithinNext45Days(dateString: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy" // Date format for your input strings

        guard let date = dateFormatter.date(from: dateString) else {
//            print("Invalid date string")
            return false
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        // Calculate the date 45 days from today
        if let date45DaysFromNow = calendar.date(byAdding: .day, value: 45, to: currentDate) {
            return date >= currentDate && date <= date45DaysFromNow
        }
        
        return false
    }
    
   
    
}

struct Scholarship {
    let title: String
    let description: String
    let amount: String
    let link: String
    let deadline: String
    let tag: String
    var favorite: Bool
}
