//
//  MGRS.swift
//  mgrs-ios
//
//  Created by Brian Osborn on 8/23/22.
//

import Foundation
import grid_ios

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
    
    /**
     * Get the hemisphere
     *
     * @return hemisphere
     */
    public func hemisphere() -> Hemisphere {
        return MGRSUtils.hemisphere(band)
    }

    /**
     * Get the MGRS coordinate with one meter precision
     *
     * @return MGRS coordinate
     */
    public func coordinate() -> String {
        return coordinate(GridType.METER)
    }

    /**
     * Get the MGRS coordinate with specified grid precision
     *
     * @param type
     *            grid type precision
     * @return MGRS coordinate
     */
    public func coordinate(_ type: GridType?) -> String {

        var mgrs = String()

        if type != nil {

            mgrs = mgrs.appending(String(zone))
            mgrs = mgrs.appending(String(band))

            if type != GridType.GZD {

                mgrs = mgrs.appending(String(column))
                mgrs = mgrs.appending(String(row))

                if type != GridType.HUNDRED_KILOMETER {

                    mgrs = mgrs.appending(eastingAndNorthing(type!))

                }

            }

        }

        return mgrs
    }
    
    /**
     * Get the easting and northing concatenated value in the grid type
     * precision
     *
     * @param type
     *            grid type precision
     * @return easting and northing value
     */
    public func eastingAndNorthing(_ type: GridType) -> String {

        let accuracy = 5 - Int(log10(Double(type.precision())))

        let easting = String(format: "%05d", self.easting)
        let northing = String(format: "%05d", self.northing)

        return String(easting.prefix(accuracy)) + String(northing.prefix(accuracy))
    }
    
    /**
     * Get the MGRS coordinate with the accuracy number of digits in the easting
     * and northing values. Accuracy must be inclusively between 0
     * (GridType.HUNDRED_KILOMETER) and 5 (GridType.METER).
     *
     * @param accuracy
     *            accuracy digits between 0 (inclusive) and 5 (inclusive)
     * @return MGRS coordinate
     */
    public func coordinate(accuracy: Int) -> String {
        return coordinate(GridType.withAccuracy(accuracy))
    }
    
    /**
     * Get the MGRS coordinate grid precision
     *
     * @return grid type precision
     */
    public func precision() -> GridType {
        return GridType.withAccuracy(accuracy())
    }

    /**
     * Get the MGRS coordinate accuracy number of digits
     *
     * @return accuracy digits
     */
    public func accuracy() -> Int {

        var accuracy = 5

        var accuracyLevel = 10
        while accuracyLevel <= 100000 {
            
            if easting % accuracyLevel != 0 || northing % accuracyLevel != 0 {
                break
            }
            accuracy -= 1
            
            accuracyLevel *= 10
        }

        return accuracy
    }
    
    /**
     * Get the two letter column and row 100k designator
     *
     * @return the two letter column and row 100k designator
     */
    public func columnRowId() -> String {
        return String(column) + String(row)
    }

    /**
     * Get the GZD grid zone
     *
     * @return GZD grid zone
     */
    public func gridZone() -> GridZone {
        return GridZones.gridZone(self)
    }
    
    /**
     * Convert to a point
     *
     * @return point
     */
    public func toPoint() -> GridPoint {
        return toUTM().toPoint()
    }

    /**
     * Convert to UTM coordinate
     *
     * @return UTM
     */
    public func toUTM() -> UTM {

        let easting = utmEasting()
        let northing = utmNorthing()
        let hemisphere = hemisphere()

        return UTM(zone, hemisphere, easting, northing)
    }
    
    /**
     * Get the UTM easting
     *
     * @return UTM easting
     */
    public func utmEasting() -> Double {

        // get easting specified by e100k
        let columnLetters = MGRS.columnLetters(zone)
        let columnIndex = columnLetters.firstIndex(of: column)!.utf16Offset(in: columnLetters) + 1
        // index+1 since A (index 0) -> 1*100e3, B (index 1) -> 2*100e3, etc.
        let e100kNum = Double(columnIndex) * 100000.0 // e100k in meters

        return e100kNum + Double(easting)
    }
    
    /**
     * Get the UTM northing
     *
     * @return UTM northing
     */
    public func utmNorthing() -> Double {

        // get northing specified by n100k
        let rowLetters = MGRS.rowLetters(zone)
        let rowIndex = rowLetters.firstIndex(of: row)!.utf16Offset(in: rowLetters)
        let n100kNum = Double(rowIndex) * 100000.0 // n100k in meters

        // get latitude of (bottom of) band
        let latBand = GridZones.southLatitude(band)

        // northing of bottom of band, extended to include entirety of
        // bottommost 100km square
        // (100km square boundaries are aligned with 100km UTM northing
        // intervals)

        let latBandNorthing = UTM.from(GridPoint.degrees(0, latBand)).northing
        let nBand = floor(latBandNorthing / 100000) * 100000

        // 100km grid square row letters repeat every 2,000km north; add enough
        // 2,000km blocks to get
        // into required band
        var n2M = 0 // northing of 2,000km block
        while Double(n2M) + n100kNum + Double(northing) < nBand {
            n2M += 2000000
        }

        return Double(n2M) + n100kNum + Double(northing)
    }
    
    public var description: String {
        return coordinate()
    }
    
    /**
     * Return whether the given string is valid MGRS string
     *
     * @param mgrs
     *            potential MGRS string
     * @return true if MGRS string is valid, false otherwise
     */
    public static func isMGRS(_ mgrs: String) -> Bool {
        let mgrsValue = removeSpaces(mgrs)
        return mgrsExpression.matches(in: mgrsValue, range: NSMakeRange(0, mgrsValue.count)).count > 0 && mgrsInvalidExpression.matches(in: mgrsValue, range: NSMakeRange(0, mgrsValue.count)).count <= 0
    }
    
    /**
     * Removed spaces from the value
     *
     * @param value
     *            value string
     * @return value without spaces
     */
    private static func removeSpaces(_ value: String) -> String {
        return value.filter { !$0.isWhitespace }
    }

    /**
     * Encodes a point as a MGRS string
     *
     * @param point
     *            point
     * @return MGRS
     */
    public static func from(_ point: GridPoint) -> MGRS {

        let pointDegrees = point.toDegrees()

        let utm = UTM.from(pointDegrees)

        let bandLetter = GridZones.bandLetter(pointDegrees.latitude)

        let columnLetter = columnLetter(utm)

        let rowLetter = rowLetter(utm)

        // truncate easting/northing to within 100km grid square
        let easting = Int(utm.easting % 100000)
        let northing = Int(utm.northing % 100000)

        return MGRS(utm.zone, bandLetter, columnLetter, rowLetter,
                easting, northing)
    }
    
    /**
     * Parse the MGRS string for the precision
     *
     * @param mgrs
     *            MGRS string
     * @return grid type precision
     */
    public static func precision(_ mgrs: String) -> GridType {
        let mgrsValue = removeSpaces(mgrs)
        let matches = mgrsExpression.matches(in: mgrsValue, range: NSMakeRange(0, mgrsValue.count))
        if matches.count <= 0 {
            preconditionFailure("Invalid MGRS: \(mgrs)")
        }

        let match = matches[0]
        
        let precision: GridType

        if match.range(at: 3).length > 0 {
            
            let mgrsString = mgrsValue as NSString

            let location = mgrsString.substring(with: match.range(at: 4))
            if (location.count > 0) {
                precision = GridType.withAccuracy(location.count / 2)
            } else {
                precision = GridType.HUNDRED_KILOMETER
            }

        } else {
            precision = GridType.GZD
        }

        return precision
    }
    
    /**
     * Get the MGRS coordinate accuracy number of digits
     *
     * @param mgrs
     *            MGRS string
     * @return accuracy digits
     */
    public static func accuracy(_ mgrs: String) -> Int {
        return precision(mgrs).accuracy()
    }
    
    /**
     * Get the two letter column and row 100k designator for a given UTM
     * easting, northing and zone number value
     *
     * @param easting
     *            easting
     * @param northing
     *            northing
     * @param zoneNumber
     *            zone number
     * @return the two letter column and row 100k designator
     */
    public static func columnRowId(_ easting: Double, _ northing: Double, _ zoneNumber: Int) -> String {

        let columnLetter = columnLetter(zoneNumber, easting)

        let rowLetter = rowLetter(zoneNumber, northing)

        return String(columnLetter) + String(rowLetter)
    }
    
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
