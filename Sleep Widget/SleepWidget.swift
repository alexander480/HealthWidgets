//
//  Sleep_Widget.swift
//  Sleep Widget
//
//  Created by Alexander Lester on 2/14/21.
//

import WidgetKit
import SwiftUI
import Intents

struct SleepEntry: TimelineEntry {
    let date: Date
    let timeInBed: TimeInterval
    let timeAsleep: TimeInterval
}

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SleepEntry { SleepEntry(date: Date(), timeInBed: .zero, timeAsleep: .zero) }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SleepEntry) -> ()) {
        
        print("[INFO] getSnapshot")
        
        // Check Authorization
        SleepHelper.checkRequestStatusForAuthorization { (isAuthorized, status) in
            if (isAuthorized) {
                
                // Fetch Data
                SleepHelper.fetchData { (sleepData) in
                    if let sleepData = sleepData { completion(SleepEntry(date: Date(), timeInBed: sleepData.timeInBed, timeAsleep: sleepData.timeAsleep)) }
                    else { completion(SleepEntry(date: Date(), timeInBed: .zero, timeAsleep: .zero)) }
                }
            }
            else {
                // TODO: Display "Authorize In App"
                print("[ERROR] Not Authorized. [MESSAGE] \(String(describing: status))")
            }
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        print("[INFO] getTimeline")
        
        guard let refreshDate = Calendar.current.date(byAdding: .minute, value: 2, to: Date()) else {
            print("[ERROR] Failed To Validate refreshDate For Widget.")
            return
        }
        
        // Check Authorization
        SleepHelper.checkRequestStatusForAuthorization { (isAuthorized, status) in
            if (isAuthorized) {
            	
                // Fetch Data
                SleepHelper.fetchData { (sleepData) in
                    if let sleepData = sleepData {
                        print("[SUCCESS] Successfully Fetched Sleep Data For Widget.")
                        
                        let entry = SleepEntry(date: Date(), timeInBed: sleepData.timeInBed, timeAsleep: sleepData.timeAsleep)
                        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                        completion(timeline)
                    }
                    else {
                        print("[ERROR] Failed To Fetch Sleep Data For Widget.")
                    }
                }
            }
            else {
                // TODO: Display "Authorize In App"
                print("[ERROR] Not Authorized. [MESSAGE] \(String(describing: status))")
            }
        }
    }
}

struct SleepWidgetView: View {
    let sleepEntry: SleepEntry

    var body: some View {

        let progress = Float(sleepEntry.timeAsleep / 28800)
        
        VStack {
            CircularProgress(progress: progress, timeAsleep: sleepEntry.timeAsleep)
        }
    }
}

@main
struct SleepWidget: Widget {
    let kind: String = "SleepWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SleepWidgetView(sleepEntry: entry)
        }
        .configurationDisplayName("Sleep")
        .description("This is widget displays your sleep data from Apple Health.")
    }
}

struct SleepWidget_Previews: PreviewProvider {
    static var previews: some View {
        let placeholderEntry = SleepEntry(date: Date(), timeInBed: .zero, timeAsleep: 8600)
        
        SleepWidgetView(sleepEntry: placeholderEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
