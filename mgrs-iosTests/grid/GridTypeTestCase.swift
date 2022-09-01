//
//  GridTypeTestCase.swift
//  mgrs-iosTests
//
//  Created by Brian Osborn on 9/1/22.
//

import XCTest
@testable import mgrs_ios

/**
 * Grid Type Test
 */
class GridTypeTestCase: XCTestCase {

    /**
     * Test precisions
     */
    func testPrecision() {
        
        XCTAssertEqual(0, GridType.GZD.precision())
        XCTAssertEqual(100000, GridType.HUNDRED_KILOMETER.precision())
        XCTAssertEqual(10000, GridType.TEN_KILOMETER.precision())
        XCTAssertEqual(1000, GridType.KILOMETER.precision())
        XCTAssertEqual(100, GridType.HUNDRED_METER.precision())
        XCTAssertEqual(10, GridType.TEN_METER.precision())
        XCTAssertEqual(1, GridType.METER.precision())
        
    }
    
    /**
     * Test digit accuracies
     */
    func testAccuracy() {
        
        XCTAssertEqual(0, GridType.GZD.accuracy())
        
        XCTAssertEqual(GridType.HUNDRED_KILOMETER, GridType.withAccuracy(0))
        XCTAssertEqual(0, GridType.HUNDRED_KILOMETER.accuracy())
        
        XCTAssertEqual(GridType.TEN_KILOMETER, GridType.withAccuracy(1))
        XCTAssertEqual(1, GridType.TEN_KILOMETER.accuracy())
        
        XCTAssertEqual(GridType.KILOMETER, GridType.withAccuracy(2))
        XCTAssertEqual(2, GridType.KILOMETER.accuracy())
        
        XCTAssertEqual(GridType.HUNDRED_METER, GridType.withAccuracy(3))
        XCTAssertEqual(3, GridType.HUNDRED_METER.accuracy())
        
        XCTAssertEqual(GridType.TEN_METER, GridType.withAccuracy(4))
        XCTAssertEqual(4, GridType.TEN_METER.accuracy())
        
        XCTAssertEqual(GridType.METER, GridType.withAccuracy(5))
        XCTAssertEqual(5, GridType.METER.accuracy())
        
    }
    
}
