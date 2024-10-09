//
//  CalendarManager.swift
//  GENIUS
//
//  Created by Rick Massa on 10/9/24.
//

import Foundation



class CalendarManager : Identifiable {
    var id: UUID
    private var meetingName : String
    private var time = ""
    private var day = ""
    
    init(meetingName : String, time : String, day : String) {
        self.id = UUID()
        self.meetingName = meetingName
        self.time = time
        self.day = day
    }
    func getName() -> String {
       return meetingName
    }
    func getTime() -> String {
       return time
    }
    func getDay() -> String {
       return day
    }
}

