//
//  MGRSTestCase.swift
//  mgrs-iosTests
//
//  Created by Brian Osborn on 9/1/22.
//

import XCTest
@testable import mgrs_ios

/**
 * MGRS Test
 */
class MGRSTestCase: XCTestCase {
    
    /**
     * Test parsing a MGRS string value
     */
    func testParse() {
        
        var mgrsValue = "33XVG74594359"
        var utmValue = "33 N 474590 8643590"
        
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        var mgrs = MGRS.parse(mgrsValue)
        XCTAssertEqual(GridType.TEN_METER, MGRS.precision(mgrsValue))
        XCTAssertEqual(4, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.TEN_METER))
        XCTAssertEqual(mgrsValue, mgrs.coordinate(4))
        XCTAssertEqual(GridType.TEN_METER, mgrs.precision())
        XCTAssertEqual(4, mgrs.accuracy())

        var utm = mgrs.toUTM()
        XCTAssertEqual(utmValue, utm.description)
        
    }
    
}
