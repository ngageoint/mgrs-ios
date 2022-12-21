//
//  MGRSTestCase.swift
//  mgrs-iosTests
//
//  Created by Brian Osborn on 9/1/22.
//

import XCTest
@testable import grid_ios
@testable import mgrs_ios
@testable import sf_ios

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
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.HUNDRED_KILOMETER))
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
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.TEN_KILOMETER))
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
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.KILOMETER))
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
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.HUNDRED_METER))
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
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.TEN_METER))
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
        XCTAssertEqual(mgrsValue, mgrs.coordinate(GridType.METER))
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
    
    /**
     * Test parsing a MGRS string value
     */
    func testCoordinate() {

        var mgrs = "35VPL0115697387"
        testCoordinate(29.06757, 63.98863, mgrs)
        testCoordinateMeters(3235787.09, 9346877.48, mgrs)

        mgrs = "39PYP7290672069"
        testCoordinate(53.51, 12.40, mgrs)
        testCoordinateMeters(5956705.95, 1391265.16, mgrs)

        mgrs = "4QFJ1234056781"
        testCoordinate(-157.916861, 21.309444, mgrs)
        testCoordinateMeters(-17579224.55, 2428814.96, mgrs)

        mgrs = "33PYJ6132198972"
        testCoordinate(17.3714337, 8.1258235, mgrs, false)
        testCoordinateMeters(1933779.15, 907610.20, mgrs, false)

    }
    
    /**
     * Test parsing point bounds
     */
    func testPointBounds() {
        
        // Max latitude tests
        
        var mgrs = "39XVP9907028094"
        var mgrs2 = "39XVN9902494603"
        var longitude = 50.920338
        var latitudeBelow = 83.7
        var latitudeAbove = 100.0
        
        var point = GridPoint.degrees(longitude, MGRSConstants.MAX_LAT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeBelow)
        XCTAssertEqual(mgrs2, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WEB_MERCATOR_MAX_LAT_RANGE)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WGS84_HALF_WORLD_LAT_HEIGHT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeAbove)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        // Max latitude and max longitude tests

        longitude += (2 * SF_WGS84_HALF_WORLD_LON_WIDTH)
        
        point = GridPoint.degrees(longitude, MGRSConstants.MAX_LAT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeBelow)
        XCTAssertEqual(mgrs2, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WEB_MERCATOR_MAX_LAT_RANGE)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WGS84_HALF_WORLD_LAT_HEIGHT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeAbove)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        // Max latitude and min longitude tests
        
        longitude -= (4 * SF_WGS84_HALF_WORLD_LON_WIDTH)
        
        point = GridPoint.degrees(longitude, MGRSConstants.MAX_LAT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeBelow)
        XCTAssertEqual(mgrs2, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WEB_MERCATOR_MAX_LAT_RANGE)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WGS84_HALF_WORLD_LAT_HEIGHT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeAbove)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        // Min latitude tests
        
        mgrs = "52CDS8938618364"
        mgrs2 = "52CDT8854707650"
        longitude = 128.4525
        latitudeAbove = -79.2
        latitudeBelow = -100.0
        
        point = GridPoint.degrees(longitude, MGRSConstants.MIN_LAT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeAbove)
        XCTAssertEqual(mgrs2, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WEB_MERCATOR_MIN_LAT_RANGE)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, -SF_WGS84_HALF_WORLD_LAT_HEIGHT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeBelow)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        // Max latitude and max longitude tests

        longitude += (2 * SF_WGS84_HALF_WORLD_LON_WIDTH)
        
        point = GridPoint.degrees(longitude, MGRSConstants.MIN_LAT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeAbove)
        XCTAssertEqual(mgrs2, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WEB_MERCATOR_MIN_LAT_RANGE)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, -SF_WGS84_HALF_WORLD_LAT_HEIGHT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeBelow)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        // Max latitude and min longitude tests
        
        longitude -= (4 * SF_WGS84_HALF_WORLD_LON_WIDTH)
        
        point = GridPoint.degrees(longitude, MGRSConstants.MIN_LAT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeAbove)
        XCTAssertEqual(mgrs2, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, SF_WEB_MERCATOR_MIN_LAT_RANGE)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, -SF_WGS84_HALF_WORLD_LAT_HEIGHT)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
        point = GridPoint.degrees(longitude, latitudeBelow)
        XCTAssertEqual(mgrs, MGRS.from(point).coordinate())
        
    }
    
    /**
     * Test parsing GZD coordinates
     */
    func testGZDParse() {
        
        let gridRange = GridRange()

        for zone in gridRange {

            let zoneNumber = zone.number()
            let bandLetter = zone.letter()

            let gzd = String(zoneNumber) + String(bandLetter)
            XCTAssertTrue(MGRS.isMGRS(gzd))
            let mgrs = MGRS.parse(gzd)
            XCTAssertNotNil(mgrs)
            XCTAssertEqual(zoneNumber, mgrs.zone)
            XCTAssertEqual(bandLetter, mgrs.band)

            let point = mgrs.toPoint()
            let southwest = zone.bounds.southwest

            XCTAssertEqual(point.longitude, southwest.longitude, accuracy: 0.0001)
            XCTAssertEqual(point.latitude, southwest.latitude, accuracy: 0.0001)

        }
        
    }
    
    /**
     * Test parsing a Svalbard MGRS string values
     */
    func testSvalbardParse() {
        
        XCTAssertTrue(MGRS.isMGRS("31X"))
        XCTAssertNotNil(MGRS.parse("31X"))
        XCTAssertFalse(MGRS.isMGRS("32X"))
        XCTAssertFalse(MGRS.isMGRS("32XMH"))
        XCTAssertFalse(MGRS.isMGRS("32XMH11"))
        XCTAssertFalse(MGRS.isMGRS("32XMH1111"))
        XCTAssertFalse(MGRS.isMGRS("32XMH111111"))
        XCTAssertFalse(MGRS.isMGRS("32XMH11111111"))
        XCTAssertFalse(MGRS.isMGRS("32XMH111111111"))
        XCTAssertTrue(MGRS.isMGRS("33X"))
        XCTAssertNotNil(MGRS.parse("33X"))
        XCTAssertFalse(MGRS.isMGRS("34X"))
        XCTAssertTrue(MGRS.isMGRS("35X"))
        XCTAssertNotNil(MGRS.parse("35X"))
        XCTAssertFalse(MGRS.isMGRS("36X"))
        XCTAssertTrue(MGRS.isMGRS("37X"))
        XCTAssertNotNil(MGRS.parse("37X"))
        
    }
    
    /**
     * Test the WGS84 coordinate with expected MGSR coordinate
     *
     * @param longitude
     *            longitude in degrees
     * @param latitude
     *            latitude in degrees
     * @param value
     *            MGRS value
     */
    private func testCoordinate(_ longitude: Double, _ latitude: Double, _ value: String) {
        testCoordinate(longitude, latitude, value, true)
    }

    /**
     * Test the WGS84 coordinate with expected MGSR coordinate
     *
     * @param longitude
     *            longitude in degrees
     * @param latitude
     *            latitude in degrees
     * @param value
     *            MGRS value
     * @param test100k
     *            set false when falls outside the grid zone
     * @throws ParseException
     *             upon failure to parse
     */
    private func testCoordinate(_ longitude: Double, _ latitude: Double, _ value: String,
            _ test100k: Bool) {
        let point = GridPoint(longitude, latitude)
        testCoordinate(point, value, test100k)
        testCoordinate(point.toMeters(), value, test100k)
    }

    /**
     * Test the WGS84 coordinate with expected MGSR coordinate
     *
     * @param longitude
     *            longitude in degrees
     * @param latitude
     *            latitude in degrees
     * @param value
     *            MGRS value
     * @throws ParseException
     *             upon failure to parse
     */
    private func testCoordinateMeters(_ longitude: Double, _ latitude: Double,
            _ value: String) {
        testCoordinateMeters(longitude, latitude, value, true)
    }

    /**
     * Test the WGS84 coordinate with expected MGSR coordinate
     *
     * @param longitude
     *            longitude in degrees
     * @param latitude
     *            latitude in degrees
     * @param value
     *            MGRS value
     * @param test100k
     *            set false when falls outside the grid zone
     * @throws ParseException
     *             upon failure to parse
     */
    private func testCoordinateMeters(_ longitude: Double, _ latitude: Double,
                                      _ value: String, _ test100k: Bool) {
        let point = GridPoint.meters(longitude, latitude)
        testCoordinate(point, value, test100k)
        testCoordinate(point.toDegrees(), value, test100k)
    }

    /**
     * Test the coordinate with expected MGSR coordinate
     *
     * @param point
     *            point
     * @param value
     *            MGRS value
     * @param test100k
     *            set false when falls outside the grid zone
     */
    private func testCoordinate(_ point: GridPoint, _ value: String, _ test100k: Bool) {

        let mgrs = MGRS.from(point)
        XCTAssertEqual(value, mgrs.description)
        XCTAssertEqual(value, mgrs.coordinate())

        let gzd = mgrs.coordinate(GridType.GZD)
        XCTAssertEqual(accuracyValue(value, -1), gzd)
        XCTAssertTrue(MGRS.isMGRS(gzd))
        let gzdMGRS = MGRS.parse(gzd)
        XCTAssertEqual(GridType.GZD, MGRS.precision(gzd))
        XCTAssertEqual(0, MGRS.accuracy(gzd))
        XCTAssertEqual(gzd, gzdMGRS.coordinate(GridType.GZD))

        let hundredKilometer = mgrs.coordinate(GridType.HUNDRED_KILOMETER)
        XCTAssertEqual(accuracyValue(value, 0), hundredKilometer)
        XCTAssertEqual(hundredKilometer, mgrs.coordinate(0))
        XCTAssertTrue(MGRS.isMGRS(hundredKilometer))
        let hundredKilometerMGRS = MGRS.parse(hundredKilometer)
        XCTAssertEqual(GridType.HUNDRED_KILOMETER,
                MGRS.precision(hundredKilometer))
        XCTAssertEqual(0, MGRS.accuracy(hundredKilometer))
        XCTAssertEqual(hundredKilometer,
                hundredKilometerMGRS.coordinate(GridType.HUNDRED_KILOMETER))
        if test100k {
            XCTAssertEqual(0, hundredKilometerMGRS.easting)
            XCTAssertEqual(0, hundredKilometerMGRS.northing)
            XCTAssertEqual(GridType.HUNDRED_KILOMETER,
                    hundredKilometerMGRS.precision())
            XCTAssertEqual(0, hundredKilometerMGRS.accuracy())
        }

        let tenKilometer = mgrs.coordinate(GridType.TEN_KILOMETER)
        XCTAssertEqual(accuracyValue(value, 1), tenKilometer)
        XCTAssertEqual(tenKilometer, mgrs.coordinate(1))
        XCTAssertTrue(MGRS.isMGRS(tenKilometer))
        let tenKilometerMGRS = MGRS.parse(tenKilometer)
        XCTAssertEqual(GridType.TEN_KILOMETER, MGRS.precision(tenKilometer))
        XCTAssertEqual(1, MGRS.accuracy(tenKilometer))
        XCTAssertEqual(tenKilometer,
                tenKilometerMGRS.coordinate(GridType.TEN_KILOMETER))
        XCTAssertEqual(easting(tenKilometer, 1),
                tenKilometerMGRS.easting)
        XCTAssertEqual(northing(tenKilometer, 1),
                tenKilometerMGRS.northing)
        XCTAssertEqual(GridType.TEN_KILOMETER, tenKilometerMGRS.precision())
        XCTAssertEqual(1, tenKilometerMGRS.accuracy())

        let kilometer = mgrs.coordinate(GridType.KILOMETER)
        XCTAssertEqual(accuracyValue(value, 2), kilometer)
        XCTAssertEqual(kilometer, mgrs.coordinate(2))
        XCTAssertTrue(MGRS.isMGRS(kilometer))
        let kilometerMGRS = MGRS.parse(kilometer)
        XCTAssertEqual(GridType.KILOMETER, MGRS.precision(kilometer))
        XCTAssertEqual(2, MGRS.accuracy(kilometer))
        XCTAssertEqual(kilometer, kilometerMGRS.coordinate(GridType.KILOMETER))
        XCTAssertEqual(easting(kilometer, 2), kilometerMGRS.easting)
        XCTAssertEqual(northing(kilometer, 2), kilometerMGRS.northing)
        XCTAssertEqual(GridType.KILOMETER, kilometerMGRS.precision())
        XCTAssertEqual(2, kilometerMGRS.accuracy())

        let hundredMeter = mgrs.coordinate(GridType.HUNDRED_METER)
        XCTAssertEqual(accuracyValue(value, 3), hundredMeter)
        XCTAssertEqual(hundredMeter, mgrs.coordinate(3))
        XCTAssertTrue(MGRS.isMGRS(hundredMeter))
        let hundredMeterMGRS = MGRS.parse(hundredMeter)
        XCTAssertEqual(GridType.HUNDRED_METER, MGRS.precision(hundredMeter))
        XCTAssertEqual(3, MGRS.accuracy(hundredMeter))
        XCTAssertEqual(hundredMeter,
                hundredMeterMGRS.coordinate(GridType.HUNDRED_METER))
        XCTAssertEqual(easting(hundredMeter, 3),
                hundredMeterMGRS.easting)
        XCTAssertEqual(northing(hundredMeter, 3),
                hundredMeterMGRS.northing)
        XCTAssertEqual(GridType.HUNDRED_METER, hundredMeterMGRS.precision())
        XCTAssertEqual(3, hundredMeterMGRS.accuracy())

        let tenMeter = mgrs.coordinate(GridType.TEN_METER)
        XCTAssertEqual(accuracyValue(value, 4), tenMeter)
        XCTAssertEqual(tenMeter, mgrs.coordinate(4))
        XCTAssertTrue(MGRS.isMGRS(tenMeter))
        let tenMeterMGRS = MGRS.parse(tenMeter)
        XCTAssertEqual(GridType.TEN_METER, MGRS.precision(tenMeter))
        XCTAssertEqual(4, MGRS.accuracy(tenMeter))
        XCTAssertEqual(tenMeter, tenMeterMGRS.coordinate(GridType.TEN_METER))
        XCTAssertEqual(easting(tenMeter, 4), tenMeterMGRS.easting)
        XCTAssertEqual(northing(tenMeter, 4), tenMeterMGRS.northing)
        XCTAssertEqual(GridType.TEN_METER, tenMeterMGRS.precision())
        XCTAssertEqual(4, tenMeterMGRS.accuracy())

        let meter = mgrs.coordinate(GridType.METER)
        XCTAssertEqual(meter, value)
        XCTAssertEqual(accuracyValue(value, 5), meter)
        XCTAssertEqual(meter, mgrs.coordinate(5))
        XCTAssertTrue(MGRS.isMGRS(meter))
        let meterMGRS = MGRS.parse(meter)
        XCTAssertEqual(GridType.METER, MGRS.precision(meter))
        XCTAssertEqual(5, MGRS.accuracy(meter))
        XCTAssertEqual(meter, meterMGRS.coordinate(GridType.METER))
        XCTAssertEqual(easting(meter, 5), meterMGRS.easting)
        XCTAssertEqual(northing(meter, 5), meterMGRS.northing)
        XCTAssertEqual(GridType.METER, meterMGRS.precision())
        XCTAssertEqual(5, meterMGRS.accuracy())
        
    }
    
    /**
     * Get the MGRS value in the accuracy digits
     *
     * @param value
     *            MGRS value
     * @param accuracy
     *            accuracy digits (-1 for GZD)
     * @return MGRS in accuracy
     */
    private func accuracyValue(_ value: String, _ accuracy: Int) -> String {

        let gzdLength = value.count % 2 == 1 ? 3 : 2
        var accuracyValue = GridUtils.substring(value, 0, gzdLength)

        if accuracy >= 0 {

            accuracyValue.append(GridUtils.substring(value, gzdLength, gzdLength + 2))

            if accuracy > 0 {

                let eastingNorthing = GridUtils.substring(value, accuracyValue.count)
                let currentAccuracy = eastingNorthing.count / 2
                let easting = GridUtils.substring(eastingNorthing, 0, currentAccuracy)
                let northing = GridUtils.substring(eastingNorthing, currentAccuracy)

                accuracyValue.append(GridUtils.substring(easting, 0, accuracy))
                accuracyValue.append(GridUtils.substring(northing, 0, accuracy))

            }

        }

        return accuracyValue
    }

    /**
     * Get the easting of the MGRS value in the accuracy
     *
     * @param value
     *            MGRS value
     * @param accuracy
     *            accuracy digits
     * @return easting
     */
    private func easting(_ value: String, _ accuracy: Int) -> Int {
        return padAccuracy(GridUtils.substring(value, value.count - 2 * accuracy,
                value.count - accuracy), accuracy)
    }

    /**
     * Get the northing of the MGRS value in the accuracy
     *
     * @param value
     *            MGRS value
     * @param accuracy
     *            accuracy digits
     * @return northing
     */
    private func northing(_ value: String, _ accuracy: Int) -> Int {
        return padAccuracy(GridUtils.substring(value, value.count - accuracy),
                accuracy)
    }

    /**
     * Pad the value with the accuracy and parse as a long
     *
     * @param value
     *            MGRS value
     * @param accuracy
     *            accuracy digits
     * @return long value
     */
    private func padAccuracy(_ value: String, _ accuracy: Int) -> Int {
        var padded = value
        for _ in accuracy ..< 5 {
            padded.append("0")
        }
        return Int(padded)!
    }
    
}
