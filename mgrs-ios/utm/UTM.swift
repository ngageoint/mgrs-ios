//
//  UTM.swift
//  mgrs-ios
//
//  Created by Brian Osborn on 8/23/22.
//

import Foundation
import Grid
import MapKit

/**
 * Universal Transverse Mercator Projection
 */
public class UTM {

    /**
     * Zone number
     */
    public let zone: Int
    
    /**
     * Hemisphere
     */
    public let hemisphere: Hemisphere
    
    /**
     * Easting
     */
    public let easting: Double
    
    /**
     * Northing
     */
    public let northing: Double
    
    /**
     * UTM string pattern
     */
    private static let utmPattern = "^(\\d{1,2})\\s*([N|S])\\s*(\\d+\\.?\\d*)\\s*(\\d+\\.?\\d*)$"
    
    /**
     * UTM regular expression
     */
    private static let utmExpression = try! NSRegularExpression(pattern: utmPattern, options: .caseInsensitive)
    
    /**
     * Create a point from the UTM attributes
     *
     * @param zone
     *            zone number
     * @param hemisphere
     *            hemisphere
     * @param easting
     *            easting
     * @param northing
     *            northing
     * @return point
     */
    public static func point(_ zone: Int, _ hemisphere: Hemisphere, _ easting: Double, _ northing: Double) -> GridPoint {
        return UTM(zone, hemisphere, easting, northing).toPoint()
    }
    
    /**
     * Initialize
     *
     * @param zone
     *            zone number
     * @param hemisphere
     *            hemisphere
     * @param easting
     *            easting
     * @param northing
     *            northing
     */
    public init(_ zone: Int, _ hemisphere: Hemisphere, _ easting: Double, _ northing: Double) {
        self.zone = zone
        self.hemisphere = hemisphere
        self.easting = easting
        self.northing = northing
    }
    
    /**
     * Convert to a point
     *
     * @return point
     */
    public func toPoint() -> GridPoint {

        var north = northing
        if hemisphere == Hemisphere.SOUTH {
            // Remove 10,000,000 meter offset used for southern hemisphere
            north -= 10000000.0
        }

        // Second eccentricity squared
        let ep2 = 0.006739496742
        // Footpoint latitude (initial approximation)
        let phi = north / 6366197.724 / 0.9996
        let cosPhi = cos(phi)
        let cosPhi2 = cosPhi * cosPhi
        let sinPhi = sin(phi)
        let sin2Phi = sin(2.0 * phi)
        let ei = easting - 500000.0

        // Radius of curvature in prime vertical
        let primeVerticalRadius = 0.9996 * 6399593.625 / sqrt(1.0 + ep2 * cosPhi2)

        // Meridional arc
        let c = ep2 * 3.0 / 4.0
        let ma1 = phi + sin2Phi / 2.0
        let ma2 = 3.0 * ma1 + sin2Phi * cosPhi2
        let ma3 = 5.0 * ma2 / 4.0 + sin2Phi * cosPhi2 * cosPhi2
        let meridionalArc = 0.9996 * 6399593.625 * (phi - c * ma1 + c * c * 5.0 / 3.0 * ma2 / 4.0 - c * c * c * 35.0 / 27.0 * ma3 / 3.0)

        // Easting correction
        let eiOverN = ei / primeVerticalRadius
        let eiCorr = ep2 * eiOverN * eiOverN / 2.0 * cosPhi2

        // Footpoint latitude (refined)
        let fp = (north - meridionalArc) / primeVerticalRadius * (1.0 - eiCorr) + phi

        // Hyperbolic-like term for easting
        let expArg = eiOverN * (1.0 - eiCorr / 3.0)
        let sinhTerm = (exp(expArg) - exp(-expArg)) / 2.0
        let cosFp = cos(fp)

        // Latitude delta correction
        let atanSinhOverCosFp = atan(sinhTerm / cosFp)
        let delta = atan(cos(atanSinhOverCosFp) * tan(fp)) - phi

        var latitude = (phi + (1.0 + ep2 * cosPhi2 - ep2 * sinPhi * cosPhi * delta * 3.0 / 2.0) * delta) * 180.0 / Double.pi
        latitude = round(latitude * 10000000)
        latitude = latitude / 10000000

        var longitude = atanSinhOverCosFp * 180.0 / Double.pi + Double(zone) * 6.0 - 183.0
        longitude = round(longitude * 10000000)
        longitude = longitude / 10000000

        return GridPoint.degrees(longitude, latitude)
    }
    
    /**
     * Convert to a MGRS coordinate
     *
     * @return MGRS
     */
    public func toMGRS() -> MGRS {
        return MGRS.from(toPoint())
    }
    
    /**
     * Convert to a location coordinate
     *
     * @return coordinate
     */
    public func toCoordinate() -> CLLocationCoordinate2D {
        return toPoint().toCoordinate()
    }
    
    /**
     * Format to a UTM string
     *
     * @return UTM string
     */
    public func format() -> String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        
        return String(format: "%02d", zone)
            + " "
            + (hemisphere == Hemisphere.NORTH ? GridConstants.NORTH_CHAR : GridConstants.SOUTH_CHAR)
            + " "
            + formatter.string(from: easting as NSNumber)!
            + " "
            + formatter.string(from: northing as NSNumber)!
    }
    
    public var description: String {
        return format()
    }
    
    /**
     * Return whether the given string is valid UTM string
     *
     * @param utm
     *            potential UTM string
     * @return true if UTM string is valid, false otherwise
     */
    public static func isUTM(_ utm: String) -> Bool {
        return utmExpression.matches(in: utm, range: NSMakeRange(0, utm.count)).count > 0
    }
    
    /**
     * Parse a UTM value (Zone N|S Easting Northing)
     *
     * @param utm
     *            UTM value
     * @return UTM
     */
    public static func parse(_ utm: String) -> UTM {
        let matches = utmExpression.matches(in: utm, range: NSMakeRange(0, utm.count))
        if matches.count <= 0 {
            preconditionFailure("Invalid UTM: \(utm)")
        }

        let match = matches[0]
        let utmString = utm as NSString
        
        let zone = Int(utmString.substring(with: match.range(at: 1)))!
        let hemisphere = utmString.substring(with: match.range(at: 2)).caseInsensitiveCompare(GridConstants.NORTH_CHAR) == .orderedSame ? Hemisphere.NORTH : Hemisphere.SOUTH
        let easting = Double(utmString.substring(with: match.range(at: 3)))!
        let northing = Double(utmString.substring(with: match.range(at: 4)))!
        
        return UTM(zone, hemisphere, easting, northing)
    }
    
    /**
     * Parse a UTM value (Zone N|S Easting Northing) into a location coordinate
     *
     * @param utm
     *            UTM value
     * @return coordinate
     */
    public static func parseToCoordinate(_ utm: String) -> CLLocationCoordinate2D {
        var coordinate = kCLLocationCoordinate2DInvalid
        if isUTM(utm) {
            coordinate = parse(utm).toCoordinate()
        }
        return coordinate
    }
    
    /**
     * Create from a point
     *
     * @param point
     *            point
     * @return UTM
     */
    public static func from(_ point: GridPoint) -> UTM {
        return from(point, GridZones.zoneNumber(point))
    }

    /**
     * Create from a point and zone number
     *
     * @param point
     *            point
     * @param zone
     *            zone number
     * @return UTM
     */
    public static func from(_ point: GridPoint, _ zone: Int) -> UTM {
        return from(point, zone, Hemisphere.from(point))
    }

    /**
     * Create from a coordinate, zone number, and hemisphere
     *
     * @param point
     *            coordinate
     * @param zone
     *            zone number
     * @param hemisphere
     *            hemisphere
     * @return UTM
     */
    public static func from(_ point: GridPoint, _ zone: Int, _ hemisphere: Hemisphere) -> UTM {

        let pointDegrees = point.toDegrees()

        let latitude = pointDegrees.latitude
        let longitude = pointDegrees.longitude

        var easting = 0.5 * log((1+cos(latitude*Double.pi/180)*sin(longitude*Double.pi/180-(6*Double(zone)-183)*Double.pi/180))/(1-cos(latitude*Double.pi/180)*sin(longitude*Double.pi/180-(6*Double(zone)-183)*Double.pi/180)))*0.9996*6399593.62/pow((1+pow(0.0820944379, 2)*pow(cos(latitude*Double.pi/180), 2)), 0.5)*(1+pow(0.0820944379,2)/2*pow((0.5*log((1+cos(latitude*Double.pi/180)*sin(longitude*Double.pi/180-(6*Double(zone)-183)*Double.pi/180))/(1-cos(latitude*Double.pi/180)*sin(longitude*Double.pi/180-(6*Double(zone)-183)*Double.pi/180)))),2)*pow(cos(latitude*Double.pi/180),2)/3)+500000
        easting = round(easting * 100) * 0.01

        var northing = (atan(tan(latitude*Double.pi/180)/cos((longitude*Double.pi/180-(6*Double(zone)-183)*Double.pi/180)))-latitude*Double.pi/180)*0.9996*6399593.625/sqrt(1+0.006739496742*pow(cos(latitude*Double.pi/180),2))*(1+0.006739496742/2*pow(0.5*log((1+cos(latitude*Double.pi/180)*sin((longitude*Double.pi/180-(6*Double(zone)-183)*Double.pi/180)))/(1-cos(latitude*Double.pi/180)*sin((longitude*Double.pi/180-(6*Double(zone)-183)*Double.pi/180)))),2)*pow(cos(latitude*Double.pi/180),2))+0.9996*6399593.625*(latitude*Double.pi/180-0.005054622556*(latitude*Double.pi/180+sin(2*latitude*Double.pi/180)/2)+4.258201531e-05*(3*(latitude*Double.pi/180+sin(2*latitude*Double.pi/180)/2)+sin(2*latitude*Double.pi/180)*pow(cos(latitude*Double.pi/180),2))/4-1.674057895e-07*(5*(3*(latitude*Double.pi/180+sin(2*latitude*Double.pi/180)/2)+sin(2*latitude*Double.pi/180)*pow(cos(latitude*Double.pi/180),2))/4+sin(2*latitude*Double.pi/180)*pow(cos(latitude*Double.pi/180),2)*pow(cos(latitude*Double.pi/180),2))/3)

        if hemisphere == Hemisphere.SOUTH {
            northing = northing + 10000000
        }

        northing = round(northing * 100) * 0.01

        return UTM(zone, hemisphere, easting, northing)
    }
    
    /**
     * Create from a coordinate
     *
     * @param coordinate
     *            coordinate
     * @return UTM
     */
    public static func from(_ coordinate: CLLocationCoordinate2D) -> UTM {
        return from(coordinate.longitude, coordinate.latitude)
    }
    
    /**
     * Create from a coordinate in degrees
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @return UTM
     */
    public static func from(_ longitude: Double, _ latitude: Double) -> UTM {
        return from(longitude, latitude, GridUnit.DEGREE)
    }
    
    /**
     * Create from a coordinate in the unit
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param unit
     *            unit
     * @return UTM
     */
    public static func from(_ longitude: Double, _ latitude: Double, _ unit: GridUnit) -> UTM {
        return from(GridPoint(longitude, latitude, unit))
    }
    
    /**
     * Create from a coordinate in degrees and zone number
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param zone
     *            zone number
     * @return UTM
     */
    public static func from(_ longitude: Double, _ latitude: Double, _ zone: Int) -> UTM {
        return from(longitude, latitude, GridUnit.DEGREE, zone)
    }
    
    /**
     * Create from a coordinate in the unit and zone number
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param unit
     *            unit
     * @param zone
     *            zone number
     * @return UTM
     */
    public static func from(_ longitude: Double, _ latitude: Double, _ unit: GridUnit, _ zone: Int) -> UTM {
        return from(GridPoint(longitude, latitude, unit), zone)
    }
    
    /**
     * Create from a coordinate in degrees, zone number, and hemisphere
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param zone
     *            zone number
     * @param hemisphere
     *            hemisphere
     * @return UTM
     */
    public static func from(_ longitude: Double, _ latitude: Double, _ zone: Int, _ hemisphere: Hemisphere) -> UTM {
        return from(longitude, latitude, GridUnit.DEGREE, zone, hemisphere)
    }
    
    /**
     * Create from a coordinate in the unit, zone number, and hemisphere
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param unit
     *            unit
     * @param zone
     *            zone number
     * @param hemisphere
     *            hemisphere
     * @return UTM
     */
    public static func from(_ longitude: Double, _ latitude: Double, _ unit: GridUnit, _ zone: Int, _ hemisphere: Hemisphere) -> UTM {
        return from(GridPoint(longitude, latitude, unit), zone, hemisphere)
    }
    
    /**
     * Format to a UTM string from a point
     *
     * @param point
     *            point
     * @return UTM string
     */
    public static func format(_ point: GridPoint) -> String {
        return from(point).format()
    }

    /**
     * Format to a UTM string from a point and zone number
     *
     * @param point
     *            point
     * @param zone
     *            zone number
     * @return UTM string
     */
    public static func format(_ point: GridPoint, _ zone: Int) -> String {
        return from(point, zone).format()
    }

    /**
     * Format to a UTM string from a coordinate, zone number, and hemisphere
     *
     * @param point
     *            coordinate
     * @param zone
     *            zone number
     * @param hemisphere
     *            hemisphere
     * @return UTM string
     */
    public static func format(_ point: GridPoint, _ zone: Int, _ hemisphere: Hemisphere) -> String {
        return from(point, zone, hemisphere).format()
    }
    
    /**
     * Format to a UTM string from a coordinate
     *
     * @param coordinate
     *            coordinate
     * @return UTM string
     */
    public static func format(_ coordinate: CLLocationCoordinate2D) -> String {
        return from(coordinate).format()
    }
    
    /**
     * Format to a UTM string from a coordinate in degrees
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @return UTM string
     */
    public static func format(_ longitude: Double, _ latitude: Double) -> String {
        return from(longitude, latitude).format()
    }
    
    /**
     * Format to a UTM string from a coordinate in the unit
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param unit
     *            unit
     * @return UTM string
     */
    public static func format(_ longitude: Double, _ latitude: Double, _ unit: GridUnit) -> String {
        return from(longitude, latitude, unit).format()
    }
    
    /**
     * Format to a UTM string from a coordinate in degrees and zone number
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param zone
     *            zone number
     * @return UTM string
     */
    public static func format(_ longitude: Double, _ latitude: Double, _ zone: Int) -> String {
        return from(longitude, latitude, zone).format()
    }
    
    /**
     * Format to a UTM string from a coordinate in the unit and zone number
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param unit
     *            unit
     * @param zone
     *            zone number
     * @return UTM string
     */
    public static func format(_ longitude: Double, _ latitude: Double, _ unit: GridUnit, _ zone: Int) -> String {
        return from(longitude, latitude, unit, zone).format()
    }
    
    /**
     * Format to a UTM string from a coordinate in degrees, zone number, and hemisphere
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param zone
     *            zone number
     * @param hemisphere
     *            hemisphere
     * @return UTM string
     */
    public static func format(_ longitude: Double, _ latitude: Double, _ zone: Int, _ hemisphere: Hemisphere) -> String {
        return from(longitude, latitude, zone, hemisphere).format()
    }
    
    /**
     * Format to a UTM string from a coordinate in the unit, zone number, and hemisphere
     *
     * @param longitude
     *            longitude
     * @param latitude
     *            latitude
     * @param unit
     *            unit
     * @param zone
     *            zone number
     * @param hemisphere
     *            hemisphere
     * @return UTM string
     */
    public static func format(_ longitude: Double, _ latitude: Double, _ unit: GridUnit, _ zone: Int, _ hemisphere: Hemisphere) -> String {
        return from(longitude, latitude, unit, zone, hemisphere).format()
    }
    
}
