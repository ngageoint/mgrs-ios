//
//  UTM.swift
//  mgrs-ios
//
//  Created by Brian Osborn on 8/23/22.
//

import Foundation
import grid_ios

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

        var latitude = (north/6366197.724/0.9996+(1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)-0.006739496742*sin(north/6366197.724/0.9996)*cos(north/6366197.724/0.9996)*(atan(cos(atan(( exp((easting - 500000) / (0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting - 500000) / (0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2)/3))-exp(-(easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*( 1 -  0.006739496742*pow((easting - 500000) / (0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2)/3)))/2/cos((north-0.9996*6399593.625*(north/6366197.724/0.9996-0.006739496742*3/4*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+pow(0.006739496742*3/4,2)*5/3*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996 )/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4-pow(0.006739496742*3/4,3)*35/27*(5*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2)*pow(cos(north/6366197.724/0.9996),2))/3))/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2))+north/6366197.724/0.9996)))*tan((north-0.9996*6399593.625*(north/6366197.724/0.9996 - 0.006739496742*3/4*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+pow(0.006739496742*3/4,2)*5/3*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996 )*pow(cos(north/6366197.724/0.9996),2))/4-pow(0.006739496742*3/4,3)*35/27*(5*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2)*pow(cos(north/6366197.724/0.9996),2))/3))/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2))+north/6366197.724/0.9996))-north/6366197.724/0.9996)*3/2)*(atan(cos(atan((exp((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2)/3))-exp(-(easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2)/3)))/2/cos((north-0.9996*6399593.625*(north/6366197.724/0.9996-0.006739496742*3/4*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+pow(0.006739496742*3/4,2)*5/3*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4-pow(0.006739496742*3/4,3)*35/27*(5*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2)*pow(cos(north/6366197.724/0.9996),2))/3))/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2))+north/6366197.724/0.9996)))*tan((north-0.9996*6399593.625*(north/6366197.724/0.9996-0.006739496742*3/4*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+pow(0.006739496742*3/4,2)*5/3*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4-pow(0.006739496742*3/4,3)*35/27*(5*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2)*pow(cos(north/6366197.724/0.9996),2))/3))/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2))+north/6366197.724/0.9996))-north/6366197.724/0.9996))*180/Double.pi
        latitude = round(latitude * 10000000)
        latitude = latitude / 10000000

        var longitude = atan((exp((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2)/3))-exp(-(easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2)/3)))/2/cos((north-0.9996*6399593.625*( north/6366197.724/0.9996-0.006739496742*3/4*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+pow(0.006739496742*3/4,2)*5/3*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4-pow(0.006739496742*3/4,3)*35/27*(5*(3*(north/6366197.724/0.9996+sin(2*north/6366197.724/0.9996)/2)+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2))/4+sin(2*north/6366197.724/0.9996)*pow(cos(north/6366197.724/0.9996),2)*pow(cos(north/6366197.724/0.9996),2))/3)) / (0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2))))*(1-0.006739496742*pow((easting-500000)/(0.9996*6399593.625/sqrt((1+0.006739496742*pow(cos(north/6366197.724/0.9996),2)))),2)/2*pow(cos(north/6366197.724/0.9996),2))+north/6366197.724/0.9996))*180/Double.pi+Double(zone)*6-183
        longitude = round(longitude * 10000000)
        longitude = longitude / 10000000

        return GridPoint.degrees(longitude, latitude)
    }
    
    /**
     * Convert to a MGRS coordinate
     *
     * @return MGRS
     */
    // TODO
    /*
    public func toMGRS() -> MGRS {
        return MGRS.from(toPoint())
    }
     */
    
    /**
     * Format to a UTM string
     *
     * @return UTM string
     */
    public func format() -> String {

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        
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
     * @throws ParseException
     *             upon failure to parse UTM value
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
     * Create from a point
     *
     * @param point
     *            point
     * @return UTM
     */
    // TODO
    /*
    public static func from(_ point: GridPoint) -> UTM {
        return from(point, GridZones.zoneNumber(point))
    }
     */

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
    
}