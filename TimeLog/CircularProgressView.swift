//
//  CircularProgressView.swift
//  TimeLog
//
//  Created by Aybars Nazlica on 2024/10/02.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double // Progress value between 0 and 1
    var elapsedTime: TimeInterval // Elapsed session time
    var durationGoal: TimeInterval // Goal duration
    var lineWidth: CGFloat = 20.0

    var body: some View {
        ZStack {
            // Background circle (gray)
            Circle()
                .stroke(
                    Color.gray.opacity(0.3),
                    lineWidth: lineWidth
                )
                .padding()
            
            // Progress circle (dynamic)
            Circle()
                .trim(from: 0.0, to: progress) // Trim based on progress value
                .stroke(
                    Color.orange,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90)) // Rotate to start from the top
                .animation(.easeInOut, value: progress) // Animate changes in progress
                .padding()
            
            // Display elapsed time and session goal in the center of the circle
            VStack {
                Text(formatDuration(elapsedTime))
                    .font(.largeTitle)
                    .bold()
                Text("of \(formatDuration(durationGoal))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 200, height: 200) // Adjust size of the progress circle
    }
    
    // Format TimeInterval into "MM:SS" (or "HH:MM:SS" if needed)
    private func formatDuration(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgressView(progress: 0.5, elapsedTime: 900, durationGoal: 1800) // 50% progress of 30 minutes
    }
}
