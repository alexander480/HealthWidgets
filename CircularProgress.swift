//
//  HealthWidgets.swift
//  HealthWidgets
//
//  Created by Alexander Lester on 2/16/21.
//

import SwiftUI
import WidgetKit

struct CircularProgress: View {
    var progress: Float
    var timeAsleep: TimeInterval
    
    private let shouldDisplayTime: Bool = true
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.gray)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear)
            
            VStack {
                if (self.shouldDisplayTime) {
                    Text(self.formatTimeString(timeAsleep: self.timeAsleep))
                        .font(.title2)
                        .bold()
                }
                else {
                    Text(String(format: "%.0f%%", min(self.progress, 1.0)*100.0))
                        .font(.title2)
                        .bold()
                }
            }
        }
        .padding(22)
    }
    
    fileprivate func formatTimeString(timeAsleep: TimeInterval) -> String {
        var minutes = Int(timeAsleep / 60)
        let hours = Int(minutes / 60)
        
        minutes = minutes - (hours * 60)
        
        var hoursStr = "\(hours)"
        var minutesStr = "\(minutes)"
        
        if (hours == 0) { hoursStr = "0\(hours)" }
        if (minutes < 10) { minutesStr = "0\(minutes)" }
        
        return "\(hoursStr):\(minutesStr)"
    }
}



struct CircularProgress_Previews: PreviewProvider {
    static var previews: some View {
        CircularProgress(progress: 0.35, timeAsleep: 3600)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
