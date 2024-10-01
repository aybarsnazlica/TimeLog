//
//  ContentView.swift
//  TimeLog
//
//  Created by Aybars Nazlica on 2024/10/01.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    @State private var timerRunning = false
    @State private var startTime: Date?
    @State private var elapsedTime: TimeInterval = 0
    @State private var durationGoal: TimeInterval = 1800 // 30 minutes (in seconds)

    // Timer that fires every second
    @State private var timer: Timer? = nil

    var body: some View {
        VStack {
            // Horizontal stack for the stopwatch and controls
            
            Spacer()
        
            HStack {
                CircularProgressView(
                    progress: progress(),
                    elapsedTime: elapsedTime,
                    durationGoal: durationGoal
                )
                .padding()
                
                VStack {
                    Button(action: toggleTimer) {
                        Label(timerRunning ? "Stop" : "Start", systemImage: timerRunning ? "pause" : "play")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    
                    VStack(alignment: .trailing) {
                        Text("Daily Total: \(formatDuration(totalDailyTime()))")
                            .padding(.bottom, 5)
                        Text("Weekly Total: \(formatDuration(totalWeeklyTime()))")
                    }
                    // Hard reset button
                    Button(action: hardReset) {
                        Text("Hard Reset")
                            .foregroundColor(.red)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            
            Divider()
            
            HStack {
                // Display list of sessions
                List {
                    ForEach(items) { item in
                        VStack(alignment: .leading) {
                            Text("Session on \(item.startTime, format: Date.FormatStyle(date: .numeric, time: .standard))")
                                .font(.headline)
                            if let endTime = item.endTime {
                                Text("Start: \(item.startTime, format: Date.FormatStyle(time: .standard))")
                                Text("End: \(endTime, format: Date.FormatStyle(time: .standard))")
                                Text("Duration: \(formatDuration(item.duration ?? 0))")
                            } else {
                                Text("Session is ongoing")
                            }
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteItems)
                }
                .padding()
            }
        }
        .onDisappear { stopTimer() }  // Ensure timer stops when view disappears
    }

    // Progress between 0 and 1 for the circular progress view
    private func progress() -> Double {
        guard durationGoal > 0 else { return 0.0 }
        return min(elapsedTime / durationGoal, 1.0) // Progress is capped at 1 (100%)
    }

    // Start or stop the timer
    private func toggleTimer() {
        withAnimation {
            if timerRunning {
                // Stop the timer and reset
                stopTimer()
                guard let startTime = startTime else { return }
                let endTime = Date()
                let duration = endTime.timeIntervalSince(startTime)
                let newItem = Item(startTime: startTime, endTime: endTime, duration: duration)
                modelContext.insert(newItem)
                self.startTime = nil
                elapsedTime = 0  // Reset elapsed time after stopping
            } else {
                // Start the timer
                startTime = Date()
                startTimer()
            }
            timerRunning.toggle()
        }
    }

    // Start a timer that updates every second
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if let startTime = self.startTime {
                elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }

    // Stop the timer
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func hardReset() {
        withAnimation {
            // Clear all logged items
            for item in items {
                modelContext.delete(item)
            }
            
            // Save changes to the model context
            do {
                try modelContext.save() // Use try to save and handle potential errors
            } catch {
                print("Failed to save context after hard reset: \(error)")
            }

            // Reset elapsed time and other related properties
            elapsedTime = 0
            timerRunning = false
            startTime = nil
        }
    }

    // Calculate total time logged today
    private func totalDailyTime() -> TimeInterval {
        let todayStart = Calendar.current.startOfDay(for: Date())
        return items.filter { Calendar.current.isDate($0.startTime, inSameDayAs: todayStart) }
            .compactMap { $0.duration }
            .reduce(0, +)
    }

    // Calculate total time logged this week
    private func totalWeeklyTime() -> TimeInterval {
        let calendar = Calendar.current
        let today = Date()

        // Start of the current week (assuming the week starts on Sunday)
        let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today

        // Filter items that occurred after the start of the week
        return items.filter { $0.startTime >= weekStart }
            .compactMap { $0.duration }
            .reduce(0, +)
    }

    // Delete selected items
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }

    // Format TimeInterval into "HH:mm:ss"
    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
