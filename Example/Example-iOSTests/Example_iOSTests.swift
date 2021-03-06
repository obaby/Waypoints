//
//  Example_iOSTests.swift
//  Example-iOSTests
//
//  Created by Andrew Shepard on 4/28/15.
//  Copyright (c) 2015 Andrew Shepard. All rights reserved.
//

import UIKit
import CoreLocation
import XCTest

class Example_iOSTests: XCTestCase {
    
    typealias LocationUpdate = (manager: CLLocationManager) -> Void
    
    class FakeLocationManager: CLLocationManager {
        let locatonUpdate: LocationUpdate
        
        init(update: LocationUpdate) {
            self.locatonUpdate = update
            super.init()
        }
        
        override func startUpdatingLocation() {
            dispatch_after(1, dispatch_get_main_queue()) { () -> Void in
                self.locatonUpdate(manager: self)
            }
        }
        
        override func stopUpdatingLocation() {
            // nothing
        }
    }
    
    func testLocationUpdateIsPublished() {
        let fakeLocationManager = FakeLocationManager { (manager) -> Void in
            let location = self.location
            manager.delegate.locationManager?(manager, didUpdateLocations: [location])
        }
        
        let locationTracker = LocationTracker(threshold: 0.0, locationManager: fakeLocationManager)
        let expectation = expectationWithDescription("Should publish location change")
        
        locationTracker.addLocationChangeObserver { (result) -> () in
            switch result {
            case .Success(let location):
                XCTAssertEqual(location.physical.coordinate.latitude, self.location.coordinate.latitude, "Latitude is wrong")
                XCTAssertEqual(location.physical.coordinate.longitude, self.location.coordinate.longitude, "Longitude is wrong")
                
                XCTAssertEqual(location.city, "Miami", "City is wrong")
                XCTAssertEqual(location.state, "FL", "State is wrong")
                XCTAssertEqual(location.neighborhood, "Allapattah", "Neighborhood is wrong")
                
                expectation.fulfill()
            case .Failure:
                XCTFail("Location should be valid")
            }
        }
        
        waitForExpectationsWithTimeout(2, handler: nil)
    }
    
    private var location: CLLocation {
        return CLLocation(latitude: 25.7877, longitude: -80.2241)
    }
}
