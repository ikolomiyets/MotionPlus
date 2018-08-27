//
//  InterfaceController.swift
//  MotionPlusWatch Extension
//
//  Created by Igor Kolomiyets on 20/08/2018.
//  Copyright © 2018 IKtech. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion


class InterfaceController: WKInterfaceController {
    let pedometer = CMPedometer()
    let altimeter = CMAltimeter()

    @IBOutlet var altitudeChange: WKInterfaceLabel!
    @IBOutlet var pressure: WKInterfaceLabel!
    @IBOutlet var numberOfSteps: WKInterfaceLabel!
    @IBOutlet var floorsAscended: WKInterfaceLabel!
    @IBOutlet var floorsDescended: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        self.floorsAscended.setText("Steps today: ---")
        self.floorsDescended.setText("Steps today: ---")
        self.numberOfSteps.setText("Steps today: ---")
        self.altitudeChange.setText("Rel Alt: ---")
        self.pressure.setText("Pressure: ---")

        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date(), withHandler: {data, error in
                if !(error != nil) {
                    if let reading = data {
                        if let tmp = reading.floorsAscended {
                            self.floorsAscended.setText("Floors up: \(String(describing: tmp.intValue))")
                        } else {
                            self.floorsAscended.setText("Floors up: n/a")
                        }
                        
                        if let tmp = reading.floorsDescended {
                            self.floorsDescended.setText("Floors down: \(String(describing: tmp.intValue))")
                        } else {
                            self.floorsDescended.setText("Floors down: n/a")
                        }
                        
                        self.numberOfSteps.setText("Steps today: \(String(describing: reading.numberOfSteps))")
                    }
                } else {
                    self.floorsAscended.setText("Floors up: error")
                    self.floorsDescended.setText("Floors down: error")
                    self.numberOfSteps.setText("Steps today: error")
                }
            })
        } else {
            self.floorsAscended.setText("Steps today: n/a")
            self.floorsDescended.setText("Steps today: n/a")
            self.numberOfSteps.setText("Steps today: n/a")
        }
        
        if CMAltimeter.isRelativeAltitudeAvailable() {
            if CMAltimeter.authorizationStatus() == .denied || CMAltimeter.authorizationStatus() == .restricted {
                return
            }
            
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.current!, withHandler: { data, error in
                if !(error != nil) {
                    if let reading = data {
                        self.altitudeChange.setText("Rel Alt: \(String(describing: reading.relativeAltitude.doubleValue))")
                        self.pressure.setText("Pressure: \(String(describing: reading.pressure.doubleValue))")
                    }
                } else {
                    self.altitudeChange.setText("Rel Alt: error")
                    self.pressure.setText("Pressure: error")
                }
            })
        } else {
            self.altitudeChange.setText("Rel Alt: n/a")
            self.pressure.setText("Pressure: n/a")
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
