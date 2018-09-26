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

precedencegroup ExtraMultiplicationPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExtraMultiplicationPrecedence
func ** (radix: Int, power: Int) -> Int {
    return Int(pow(Double(radix), Double(power)))
}

extension Double {
    func toFixed(_ precision: Int) -> Double {
        let factor: Double = Double(10 ** precision)
        return (self * factor).rounded() / factor
    }
}

class InterfaceController: WKInterfaceController {
    let pedometer = CMPedometer()
    let altimeter = CMAltimeter()
    var startTime = Date()
    var endTime = Date()
    let cal = Calendar(identifier: .gregorian)

    @IBOutlet var altitudeChange: WKInterfaceLabel!
    @IBOutlet var pressure: WKInterfaceLabel!
    @IBOutlet var numberOfSteps: WKInterfaceLabel!
    @IBOutlet var floorsAscended: WKInterfaceLabel!
    @IBOutlet var floorsDescended: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        setUpDates()
        
        self.floorsAscended.setText("Floors up: ---")
        self.floorsDescended.setText("Floors down: ---")
        self.numberOfSteps.setText("Steps today: ---")
        self.altitudeChange.setText("Rel Alt: ---")
        self.pressure.setText("Pressure: ---")

        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: startTime, withHandler: handlePedometerUpdates(data:error:))
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
                        self.altitudeChange.setText("Rel Alt: \(String(describing: reading.relativeAltitude.doubleValue.toFixed(2)))")
                        self.pressure.setText("Pressure: \(String(describing: reading.pressure.doubleValue.toFixed(2)))")
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
    
    func handlePedometerUpdates(data: CMPedometerData?, error: Error?){
        if !(error != nil) {
            if (Date() > endTime) {
                self.pedometer.stopUpdates()
                setUpDates()
                self.pedometer.startUpdates(from: self.startTime, withHandler: handlePedometerUpdates(data:error:))
            } else {
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
            }
        } else {
            self.floorsAscended.setText("Floors up: \(error ?? "" as! Error)")
            self.floorsDescended.setText("Floors down: \(error ?? "" as! Error)")
            self.numberOfSteps.setText("Steps today: \(error ?? "" as! Error)")
        }
    }
    
    func setUpDates() {
        startTime = cal.startOfDay(for: startTime)
        endTime = cal.date(byAdding: .day, value: 1, to: startTime)!
    }
}
