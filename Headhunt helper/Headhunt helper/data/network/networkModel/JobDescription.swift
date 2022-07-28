//
//  JobDescription.swift
//  Headhunt helper
//
//  Created by Pham Le Tuan Nam on 27/07/2022.
//

import Foundation

struct JobDescription: Decodable {
    var id: Int? = nil
    var idPosition: Int? = nil
    var jobDescription: String
    var noOfJobs: Int
    var dueDate: String
    
    init(id: Int? = nil, idPosition: Int? = nil, jobDescription: String, noOfJobs: Int, dueDate: String) {
        self.id = id
        self.idPosition = idPosition
        self.jobDescription = jobDescription
        self.noOfJobs = noOfJobs
        self.dueDate = dueDate
    }
}

struct Position: Decodable {
    var id: Int? = nil
    var idDepartment: Int? = nil
    var name: String
    
    init(id: Int? = nil, idDepartment: Int? = nil, name: String) {
        self.id = id
        self.idDepartment = idDepartment
        self.name = name
    }
}
