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
        
        mgrsValue = "33X VG 74596 43594"
        utmValue = "33 N 474596 8643594"

        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue.lowercased())
        XCTAssertEqual(GridType.METER, MGRS.precision(mgrsValue))
        XCTAssertEqual(5, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(mgrsValue.replacingOccurrences(of: " ", with: ""), mgrs.description)

        utm = mgrs.toUTM()
        XCTAssertEqual(utmValue, utm.description)
        
        XCTAssertTrue(UTM.isUTM(utmValue))
        utm = UTM.parse(utmValue)
        XCTAssertEqual(utmValue, utm.description)

        mgrs = utm.toMGRS()
        XCTAssertEqual(mgrsValue.replacingOccurrences(of: " ", with: ""), mgrs.description)

        utmValue = "33 N 474596.26 8643594.54"

        XCTAssertTrue(UTM.isUTM(utmValue))
        utm = UTM.parse(utmValue.lowercased())
        XCTAssertEqual(utmValue, utm.description)

        mgrs = utm.toMGRS()
        XCTAssertEqual(mgrsValue.replacingOccurrences(of: " ", with: ""), mgrs.description)
        
        mgrsValue = "33X"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        XCTAssertEqual(GridType.GZD, MGRS.precision(mgrsValue))
        XCTAssertEqual(0, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(33, mgrs.zone)
        XCTAssertEqual("X", mgrs.band)
        XCTAssertEqual("T", mgrs.column)
        XCTAssertEqual("V", mgrs.row)
        XCTAssertEqual("TV", mgrs.columnRowId())
        XCTAssertEqual(93363, mgrs.easting)
        XCTAssertEqual(99233, mgrs.northing)
        XCTAssertEqual("33XTV9336399233", mgrs.coordinate())
        var point = mgrs.toPoint()
        XCTAssertEqual(9.0, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(72.0, point.latitude, accuracy: 0.0001)
        XCTAssertEqual(GridType.METER, mgrs.precision())
        XCTAssertEqual(5, mgrs.accuracy())
        
        mgrsValue = "33XVG"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        XCTAssertEqual(GridType.HUNDRED_KILOMETER, MGRS.precision(mgrsValue))
        XCTAssertEqual(0, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(33, mgrs.zone)
        XCTAssertEqual("X", mgrs.band)
        XCTAssertEqual("V", mgrs.column)
        XCTAssertEqual("G", mgrs.row)
        XCTAssertEqual("VG", mgrs.columnRowId())
        XCTAssertEqual(0, mgrs.easting)
        XCTAssertEqual(0, mgrs.northing)
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.HUNDRED_KILOMETER));
        XCTAssertEqual("33XVG0000000000", mgrs.coordinate())
        point = mgrs.toPoint()
        XCTAssertEqual(10.8756458, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(77.4454720, point.latitude, accuracy: 0.0001)
        XCTAssertEqual(GridType.HUNDRED_KILOMETER, mgrs.precision())
        XCTAssertEqual(0, mgrs.accuracy())
        
        mgrsValue = "33XVG74"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        XCTAssertEqual(GridType.TEN_KILOMETER, MGRS.precision(mgrsValue))
        XCTAssertEqual(1, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(33, mgrs.zone)
        XCTAssertEqual("X", mgrs.band)
        XCTAssertEqual("V", mgrs.column)
        XCTAssertEqual("G", mgrs.row)
        XCTAssertEqual("VG", mgrs.columnRowId())
        XCTAssertEqual(70000, mgrs.easting)
        XCTAssertEqual(40000, mgrs.northing)
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.TEN_KILOMETER));
        XCTAssertEqual("33XVG7000040000", mgrs.coordinate())
        point = mgrs.toPoint()
        XCTAssertEqual(13.7248758, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(77.8324735, point.latitude, accuracy: 0.0001)
        XCTAssertEqual(GridType.TEN_KILOMETER, mgrs.precision())
        XCTAssertEqual(1, mgrs.accuracy())
        
        mgrsValue = "33XVG7443"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        XCTAssertEqual(GridType.KILOMETER, MGRS.precision(mgrsValue))
        XCTAssertEqual(2, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(33, mgrs.zone)
        XCTAssertEqual("X", mgrs.band)
        XCTAssertEqual("V", mgrs.column)
        XCTAssertEqual("G", mgrs.row)
        XCTAssertEqual("VG", mgrs.columnRowId())
        XCTAssertEqual(74000, mgrs.easting)
        XCTAssertEqual(43000, mgrs.northing)
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.KILOMETER));
        XCTAssertEqual("33XVG7400043000", mgrs.coordinate())
        point = mgrs.toPoint()
        XCTAssertEqual(13.8924385, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(77.8600782, point.latitude, accuracy: 0.0001)
        XCTAssertEqual(GridType.KILOMETER, mgrs.precision())
        XCTAssertEqual(2, mgrs.accuracy())
        
        mgrsValue = "33XVG745435"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        XCTAssertEqual(GridType.HUNDRED_METER, MGRS.precision(mgrsValue))
        XCTAssertEqual(3, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(33, mgrs.zone)
        XCTAssertEqual("X", mgrs.band)
        XCTAssertEqual("V", mgrs.column)
        XCTAssertEqual("G", mgrs.row)
        XCTAssertEqual("VG", mgrs.columnRowId())
        XCTAssertEqual(74500, mgrs.easting)
        XCTAssertEqual(43500, mgrs.northing)
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.HUNDRED_METER));
        XCTAssertEqual("33XVG7450043500", mgrs.coordinate())
        point = mgrs.toPoint()
        XCTAssertEqual(13.9133378, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(77.8646415, point.latitude, accuracy: 0.0001)
        XCTAssertEqual(GridType.HUNDRED_METER, mgrs.precision())
        XCTAssertEqual(3, mgrs.accuracy())
        
        mgrsValue = "33XVG74594359"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        XCTAssertEqual(GridType.TEN_METER, MGRS.precision(mgrsValue))
        XCTAssertEqual(4, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(33, mgrs.zone)
        XCTAssertEqual("X", mgrs.band)
        XCTAssertEqual("V", mgrs.column)
        XCTAssertEqual("G", mgrs.row)
        XCTAssertEqual("VG", mgrs.columnRowId())
        XCTAssertEqual(74590, mgrs.easting)
        XCTAssertEqual(43590, mgrs.northing)
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.TEN_METER));
        XCTAssertEqual("33XVG7459043590", mgrs.coordinate())
        point = mgrs.toPoint()
        XCTAssertEqual(13.9171014, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(77.8654628, point.latitude, accuracy: 0.0001)
        XCTAssertEqual(GridType.TEN_METER, mgrs.precision())
        XCTAssertEqual(4, mgrs.accuracy())
        
        mgrsValue = "33XVG7459743593"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        XCTAssertEqual(GridType.METER, MGRS.precision(mgrsValue))
        XCTAssertEqual(5, MGRS.accuracy(mgrsValue))
        XCTAssertEqual(33, mgrs.zone)
        XCTAssertEqual("X", mgrs.band)
        XCTAssertEqual("V", mgrs.column)
        XCTAssertEqual("G", mgrs.row)
        XCTAssertEqual("VG", mgrs.columnRowId())
        XCTAssertEqual(74597, mgrs.easting)
        XCTAssertEqual(43593, mgrs.northing)
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.METER));
        XCTAssertEqual("33XVG7459743593", mgrs.coordinate())
        point = mgrs.toPoint()
        XCTAssertEqual(13.9173973, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(77.8654908, point.latitude, accuracy: 0.0001)
        XCTAssertEqual(GridType.METER, mgrs.precision())
        XCTAssertEqual(5, mgrs.accuracy())
        
    }
    
    /**
     * Test parsing a 100k MGRS string value that falls outside grid zone bounds
     */
    func testParse100kBounds() {
        
        var mgrsValue = "32VJN"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        var mgrs = MGRS.parse(mgrsValue)
        var point = mgrs.toPoint()
        XCTAssertEqual(3.0, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(60.3007719, point.latitude, accuracy: 0.0001)
        var comparePoint = MGRS.parse(mgrs.coordinate()).toPoint()
        XCTAssertEqual(comparePoint.longitude, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(comparePoint.latitude, point.latitude, accuracy: 0.0001)
        
        mgrsValue = "32VKS"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        point = mgrs.toPoint()
        XCTAssertEqual(3.0, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(63.9024981, point.latitude, accuracy: 0.0001)
        comparePoint = MGRS.parse(mgrs.coordinate()).toPoint()
        XCTAssertEqual(comparePoint.longitude, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(comparePoint.latitude, point.latitude, accuracy: 0.0001)
        
        mgrsValue = "32VJR"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        point = mgrs.toPoint()
        XCTAssertEqual(3.0, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(63.0020546, point.latitude, accuracy: 0.0001)
        comparePoint = MGRS.parse(mgrs.coordinate()).toPoint()
        XCTAssertEqual(comparePoint.longitude, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(comparePoint.latitude, point.latitude, accuracy: 0.0001)
        
        mgrsValue = "32VJH"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        point = mgrs.toPoint()
        XCTAssertEqual(3.0, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(56.0, point.latitude, accuracy: 0.0001)
        comparePoint = MGRS.parse(mgrs.coordinate()).toPoint()
        XCTAssertEqual(comparePoint.longitude, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(comparePoint.latitude, point.latitude, accuracy: 0.0001)
        
        mgrsValue = "38KNU"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        point = mgrs.toPoint()
        XCTAssertEqual(45.0, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(-24.0, point.latitude, accuracy: 0.0001)
        comparePoint = MGRS.parse(mgrs.coordinate()).toPoint()
        XCTAssertEqual(comparePoint.longitude, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(comparePoint.latitude, point.latitude, accuracy: 0.0001)
        
        mgrsValue = "38KRU"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        point = mgrs.toPoint()
        XCTAssertEqual(47.9486444, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(-24.0, point.latitude, accuracy: 0.0001)
        comparePoint = MGRS.parse(mgrs.coordinate()).toPoint()
        XCTAssertEqual(comparePoint.longitude, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(comparePoint.latitude, point.latitude, accuracy: 0.0001)
        
        mgrsValue = "32VPH"
        XCTAssertTrue(MGRS.isMGRS(mgrsValue))
        mgrs = MGRS.parse(mgrsValue)
        point = mgrs.toPoint()
        XCTAssertEqual(10.6034691, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(56.0, point.latitude, accuracy: 0.0001)
        comparePoint = MGRS.parse(mgrs.coordinate()).toPoint()
        XCTAssertEqual(comparePoint.longitude, point.longitude, accuracy: 0.0001)
        XCTAssertEqual(comparePoint.latitude, point.latitude, accuracy: 0.0001)
        
    }
    
}
