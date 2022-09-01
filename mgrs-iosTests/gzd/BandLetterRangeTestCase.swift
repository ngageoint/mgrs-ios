//
//  BandLetterRangeTestCase.swift
//  mgrs-iosTests
//
//  Created by Brian Osborn on 9/1/22.
//

import XCTest
@testable import grid_ios
@testable import mgrs_ios

/**
 * Band Letter Range test
 */
class BandLetterRangeTestCase: XCTestCase {

    /**
     * Band Letters
     */
    public static let BAND_LETTERS = "CDEFGHJKLMNPQRSTUVWXX"
    
    /**
     * Test the full range
     */
    func testFullRange() {
        
        let bandLetters = BandLetterRangeTestCase.BAND_LETTERS
        let bandRange = BandLetterRange()
        for bandLetter in bandRange {
            XCTAssertEqual(GridZones.southLatitude(bandLetter),
                           Double(GridUtils.indexOf(bandLetters, bandLetter) - 10) * 8.0, accuracy: 0.0)
        }
        
    }
    
}
