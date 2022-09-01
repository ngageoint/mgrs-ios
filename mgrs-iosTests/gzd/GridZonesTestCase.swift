//
//  GridZonesTestCase.swift
//  mgrs-iosTests
//
//  Created by Brian Osborn on 9/1/22.
//

import XCTest
@testable import grid_ios
@testable import mgrs_ios

/**
 * Grid Zones Test
 */
class GridZonesTestCase: XCTestCase {
    
    /**
     * Test zone numbers
     */
    func testZoneNumbers() {
        
        var zoneNumber = MGRSConstants.MIN_ZONE_NUMBER
        for longitude in stride(from: MGRSConstants.MIN_LON, through: MGRSConstants.MAX_LON, by: MGRSConstants.ZONE_WIDTH) {

            let west = (longitude > MGRSConstants.MIN_LON
                    && longitude < MGRSConstants.MAX_LON) ? zoneNumber - 1
                            : zoneNumber
            let east = zoneNumber

            if longitude < MGRSConstants.MAX_LON {
                XCTAssertEqual(east,
                        Int(floor(longitude / 6 + 31)))
            }

            XCTAssertEqual(west, GridZones.zoneNumber(longitude, false))
            XCTAssertEqual(east, GridZones.zoneNumber(longitude, true))
            XCTAssertEqual(east, GridZones.zoneNumber(longitude))

            if zoneNumber < MGRSConstants.MAX_ZONE_NUMBER {
                zoneNumber += 1
            }

        }
        
    }
    
    /**
     * Test band letters
     */
    func testBandLetters() {
        
        let bandLetters = BandLetterRangeTestCase.BAND_LETTERS
        var bandLetter = MGRSConstants.MIN_BAND_LETTER
        var latitude = MGRSConstants.MIN_LAT
        while latitude <= MGRSConstants.MAX_LAT {

            let south = (latitude > MGRSConstants.MIN_LAT
                         && latitude < 80.0) ? MGRSUtils.previousBandLetter(bandLetter)
                            : bandLetter
            let north = bandLetter
            
            XCTAssertEqual(north, GridUtils.charAt(bandLetters, Int(floor(latitude / 8 + 10))))

            XCTAssertEqual(south, GridZones.bandLetter(latitude, false))
            XCTAssertEqual(north, GridZones.bandLetter(latitude, true))
            XCTAssertEqual(north, GridZones.bandLetter(latitude))

            if bandLetter < MGRSConstants.MAX_BAND_LETTER {
                bandLetter = MGRSUtils.nextBandLetter(bandLetter)
            }

            latitude += (latitude < 80.0 ? MGRSConstants.BAND_HEIGHT : 4.0)
        }
        
    }
    
}
