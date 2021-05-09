//
//  ContentView.swift
//  HealthWidgets
//
//  Created by Alexander Lester on 2/14/21.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @StateObject var sleepModel = SleepModel()
    
    var body: some View {
        
        VStack {
            let minutesInBed = String(describing: self.sleepModel.sleepData.timeInBed / 60)
            Text(minutesInBed)
            
            let minutesAsleep = String(describing: self.sleepModel.sleepData.timeAsleep / 60)
            Text(minutesAsleep)
        }
        .onAppear(perform: {
            self.sleepModel.update()
        })
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(SleepModel())
    }
}
