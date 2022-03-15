//
//  CourseDownloader.swift
//  CRNConverter
//
//  Created by Fletcher Wells on 3/8/22.
//

import Foundation

//arina changed this
// ajay changed this
class CourseDownloader {
    struct TermResponse: Codable {
        let terms: [String]
    }
    
    static func downloadTerms(completion: @escaping ([Term]) -> Void) {
        var terms: [Term] = []
        
        let url = URL(string: "https://gt-scheduler.github.io/crawler/index.json")!
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let data = data else {
                print(error?.localizedDescription ?? "error")
                completion(terms)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            if let termResponse = try? jsonDecoder.decode(TermResponse.self, from: data) {
                
                for termId in termResponse.terms {
                    let term = Term(id: termId)
                    terms.append(term)
                }
                completion(terms)
            }
            
        }
        
        task.resume()
    }
    
    
    static func downloadSections(termId: String, completion: @escaping ([String: CourseSection]) -> Void) {
        
        let url = URL(string: "https://gt-scheduler.github.io/crawler/\(termId).json")!
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print(error?.localizedDescription ?? "error")
                completion([:])
                return
            }
            
            let json = try? JSONSerialization.jsonObject(with: data, options: [])

            if let rootDictionary = json as? [String: Any] {
                if let courseDictionary = rootDictionary["courses"] as? [String: [Any]] {
                    var crn2section: [String: CourseSection] = [:]
                    for (courseId, courseArr) in courseDictionary {
                        let longTitle: String = courseArr[0] as! String
                        // let prereqs = value[2]
                        let description: String? = courseArr[3] as? String
                        
                        let course = Course(id: courseId, longTitle: longTitle, description: description)
                        
                        var sections: [CourseSection] = []
                        if let sectionDictionary = courseArr[1] as? [String: [Any]] {
                            for (sectionLabel, sectionArr) in sectionDictionary {
                                let crn = sectionArr[0] as! String
                                let section = CourseSection(crn: crn, sectionLabel: sectionLabel, course: course)
                                sections.append(section)
                                crn2section[crn] = section
                            }
                        }
                    }
                    completion(crn2section)
                }
            }
            
        }
        task.resume()
        
    }
}
