//
//  MGRS.swift
//  mgrs-ios
//
//  Created by Brian Osborn on 8/23/22.
//

import Foundation

/**
 * Military Grid Reference System Coordinate
 */
public class MGRS {
    
    /**
     * 100km grid square column (‘e’) letters repeat every third zone
     */
    private static let columnLetters: [String] = [ "ABCDEFGH", "JKLMNPQR", "STUVWXYZ" ]

    /**
     * 100km grid square row (‘n’) letters repeat every other zone
     */
    private static let rowLetters: [String] = [ "ABCDEFGHJKLMNPQRSTUV", "FGHJKLMNPQRSTUVABCDE" ]
    
    /**
     * MGRS string pattern
     */
    private static let mgrsPattern = "^(\\d{1,2})([C-HJ-NP-X])(?:([A-HJ-NP-Z][A-HJ-NP-V])((\\d{2}){0,5}))?$"
    
    /**
     * MGRS regular expression
     */
    private static let mgrsExpression = try! NSRegularExpression(pattern: mgrsPattern, options: .caseInsensitive)
    
    /**
     * MGRS invalid string pattern (Svalbard)
     */
    private static let mgrsInvalidPattern = "^3[246]X.*$"
    
    /**
     * MGRS invalid regular expression (Svalbard)
     */
    private static let mgrsInvalidExpression = try! NSRegularExpression(pattern: mgrsInvalidPattern, options: .caseInsensitive)
    
    /**
     * Zone number
     */
    let zone: Int

    /**
     * Band letter
     */
    let band: Character

    /**
     * Column letter
     */
    let column: Character

    /**
     * Row letter
     */
    let row: Character

    /**
     * Easting
     */
    let easting: Int

    /**
     * Northing
     */
    let northing: Int
    
    /**
     * Initialize
     *
     * @param zone
     *            zone number
     * @param band
     *            band letter
     * @param column
     *            column letter
     * @param row
     *            row letter
     * @param easting
     *            easting
     * @param northing
     *            northing
     */
    public init(_ zone: Int, _ band: Character, _ column: Character, _ row: Character, _ easting: Int, _ northing: Int) {
        self.zone = zone
        self.band = band
        self.column = column
        self.row = row
        self.easting = easting
        self.northing = northing
    }
    
    /**
     * Initialize
     *
     * @param zone
     *            zone number
     * @param band
     *            band letter
     * @param column
     *            column letter
     * @param row
     *            row letter
     * @param easting
     *            easting
     * @param northing
     *            northing
     */
    public convenience init(_ zone: Int, _ band: Character, _ easting: Int, _ northing: Int) {
        self.init(zone, band, MGRS.columnLetter(zone, Double(easting)), MGRS.rowLetter(zone, Double(northing)), easting, northing)
    }
    
    // TODO
    
    /**
     * Get the column letter from the UTM
     *
     * @param utm
     *            UTM
     * @return column letter
     */
    public static func columnLetter(_ utm: UTM) -> Character {
        return columnLetter(utm.zone, utm.easting)
    }

    /**
     * Get the column letter from the zone number and easting
     *
     * @param zoneNumber
     *            zone number
     * @param easting
     *            easting
     * @return column letter
     */
    public static func columnLetter(_ zoneNumber: Int, _ easting: Double) -> Character {
        // columns in zone 1 are A-H, zone 2 J-R, zone 3 S-Z, then repeating
        // every 3rd zone
        let column = Int(floor(easting / 100000))
        let columnLetters = columnLetters(zoneNumber)
        return columnLetters[columnLetters.index(columnLetters.startIndex, offsetBy: column - 1)]
    }

    /**
     * Get the row letter from the UTM
     *
     * @param utm
     *            UTM
     * @return row letter
     */
    public static func rowLetter(_ utm: UTM) -> Character {
        return rowLetter(utm.zone, utm.northing)
    }

    /**
     * Get the row letter from the zone number and northing
     *
     * @param zoneNumber
     *            zone number
     * @param northing
     *            northing
     * @return row letter
     */
    public static func rowLetter(_ zoneNumber: Int, _ northing: Double) -> Character {
        // rows in even zones are A-V, in odd zones are F-E
        let row = Int(floor(northing / 100000)) % 20
        let rowLetters = rowLetters(zoneNumber)
        return rowLetters[rowLetters.index(rowLetters.startIndex, offsetBy: row)]
    }

    /**
     * Get the column letters for the zone number
     *
     * @param zoneNumber
     *            zone number
     * @return column letters
     */
    private static func columnLetters(_ zoneNumber: Int) -> String {
        return columnLetters[columnLetters.index(columnLetters.startIndex, offsetBy: (zoneNumber - 1) % 3)]
    }

    /**
     * Get the row letters for the zone number
     *
     * @param zoneNumber
     *            zone number
     * @return row letters
     */
    private static func rowLetters(_ zoneNumber: Int) -> String {
        return rowLetters[rowLetters.index(rowLetters.startIndex, offsetBy: (zoneNumber - 1) % 2)]
    }
    
}
