//
//  CalendarView.swift
//  GENIUS
//
//  Created by Rick Massa on 7/22/24.
//
import SwiftUI

struct CalendarView: View {
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var isAddingEvent = false
    @State private var events: [Date: [String]] = [:]
    
    private var days: [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        return dateFormatter.shortWeekdaySymbols
    }
    
    private var gridItems: [GridItem] {
        Array(repeating: .init(.flexible()), count: 7)
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                }) {
                    Image(systemName: "chevron.left")
                }
                .padding()
                
                Spacer()
                
                Text(monthYearFormatter.string(from: currentDate))
                    .font(.title)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                }) {
                    Image(systemName: "chevron.right")
                }
                .padding()
            }
            .padding()
            
            HStack {
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                }
            }
            
            LazyVGrid(columns: gridItems, spacing: 20) {
                ForEach(getMonthDates(), id: \.self) { date in
                    if Calendar.current.isDate(date, equalTo: Date.distantPast, toGranularity: .day) {
                        Text("")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        let isPast = Calendar.current.isDateInPast(date: date)
                        Text("\(Calendar.current.component(.day, from: date))")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(events[date] != nil ? Color.blue.opacity(0.5) : Color.gray.opacity(0.2))
                            .cornerRadius(5)
                            .overlay(
                                Calendar.current.isDate(date, inSameDayAs: Date()) ?
                                    RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.red, lineWidth: 2)
                                    : nil
                            )
                            .opacity(isPast ? 0.3 : 1.0)
                            .onTapGesture {
                                selectedDate = date
                                isAddingEvent = true
                            }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $isAddingEvent) {
            if let selectedDate = selectedDate {
                AddEventView(date: selectedDate, events: $events)
            }
        }
    }
    
    private func getMonthDates() -> [Date] {
        var dates = [Date]()
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: currentDate) else { return dates }
        
        let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                dates.append(date)
            }
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        for _ in 1..<firstWeekday {
            dates.insert(Date.distantPast, at: 0) // Placeholder for empty days at start
        }
        
        return dates
    }
}

extension Calendar {
    func isDateInPast(date: Date) -> Bool {
        return date < Date().startOfDay
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}

struct AddEventView: View {
    let date: Date
    @Binding var events: [Date: [String]]
    @State private var eventText = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Add Event for \(dateFormatter.string(from: date))")
                    .font(.headline)
                    .padding()
                
                TextField("Event Description", text: $eventText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    addEvent()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add Event")
                        .bold()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Add Event")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }
    
    private func addEvent() {
        if events[date] != nil {
            events[date]?.append(eventText)
        } else {
            events[date] = [eventText]
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
