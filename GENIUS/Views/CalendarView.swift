//
//  CalendarView.swift
//  GENIUS
//
//  Created by Rick Massa on 7/22/24.
//
import SwiftUI

class EventManager: ObservableObject {
    @Published var events: [Date: [String]] = [:]
    @ObservedObject var updatingTextHolder = UpdatingTextHolder.shared

    func updateEvents() {
        let calendar = Calendar.current
        for manager in updatingTextHolder.calendarManager {
            if let date = getDateFromDay(manager.getDay()) {
                let event = "\(manager.getName()) at \(manager.getTime())"
                let key = calendar.startOfDay(for: date)
                if events[key] != nil {
                    events[key]?.append(event)
                } else {
                    events[key] = [event]
                }
            }
        }
    }
    
    // Converts the day string to Date
    private func getDateFromDay(_ day: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: day)
    }

    // Retrieves events for a specific date
    func events(for date: Date) -> [String] {
        let key = Calendar.current.startOfDay(for: date)
        return events[key] ?? []
    }
}

struct CalendarView: View {
    @StateObject private var eventManager = EventManager()
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                }
                
                Spacer()
                
                Button(action: {
                    selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
                }) {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            }
            
            CalendarGridView(selectedDate: $selectedDate)
                .environmentObject(eventManager)
            
            Divider()
            
            if !eventManager.events(for: selectedDate).isEmpty {
                Text("Events on \(formattedDate(selectedDate)):")
                    .font(.headline)
                List(eventManager.events(for: selectedDate), id: \.self) { event in
                    Text(event)
                }
            } else {
                Text("No events on \(formattedDate(selectedDate))")
                    .font(.headline)
            }
        }
        .padding()
        .onAppear {
            eventManager.updateEvents()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct CalendarGridView: View {
    @Binding var selectedDate: Date
    @EnvironmentObject var eventManager: EventManager
    
    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    var body: some View {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let monthName = formattedMonthYear(selectedDate)
        
        VStack {
            Text(monthName)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                ForEach(daysInMonth, id: \.self) { date in
                    let hasEvents = !eventManager.events(for: date).isEmpty
                    let isToday = calendar.isDate(date, inSameDayAs: today)
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    
                    Text("\(calendar.component(.day, from: date))")
                        .padding()
                        .background(isSelected ? Color.blue : Color.clear)
                        .cornerRadius(8)
                        .foregroundColor(isToday ? .white : .primary)
                        .opacity(date < today && !isSelected ? 0.5 : 1.0)
                        .background(hasEvents ? Color.blue.opacity(0.3) : Color.clear)
                        .cornerRadius(8)
                        .onTapGesture {
                            selectedDate = date
                        }
                }
            }
        }
    }
    
    private func formattedMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
