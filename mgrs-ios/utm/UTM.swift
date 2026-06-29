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
     * Code from: https://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html translated into swift
     * Converts UTM zone/easting/northing coordinate to latitude/longitude.
     *
     * Implements Karney’s method, using Krüger series to order n⁶, giving results accurate to 5nm
     * for distances up to 3900km from the central meridian.
     *
     * @param   {Utm} utmCoord - UTM coordinate to be converted to latitude/longitude.
     * @returns {LatLon} Latitude/longitude of supplied grid reference.
     *
     * @example
     *   const grid = new Utm(31, 'N', 448251.795, 5411932.678);
     *   const latlong = grid.toLatLon(); // 48°51′29.52″N, 002°17′40.20″E
     */
    public func toPoint() -> GridPoint {
        let falseEasting = 500000.0, falseNorthing = 10000000.0;
        let a = 6_378_137.0
        let f = 1.0 / 298.257223563
        //
        let k0 = 0.9996; // UTM scale on the central meridian

        let x = easting - falseEasting;                            // make x ± relative to central meridian
        let y = hemisphere == .SOUTH ? northing - falseNorthing : northing; // make y ± relative to equator

        // ---- from Karney 2011 Eq 15-22, 36:
        
        let e = sqrt(f*(2-f)); // eccentricity
        let n = f / (2 - f);        // 3rd flattening
        let n2 = n*n, n3 = n*n2, n4 = n*n3, n5 = n*n4, n6 = n*n5;

        let A = a/(1+n) * (1 + 1/4*n2 + 1/64*n4 + 1/256*n6); // 2πA is the circumference of a meridian

        let eta = x / (k0*A);
        let xi = y / (k0*A);

        let beta = [ 0, // note beta is one-based array (6th order Krüger expressions)
                    1/2*n - 2/3*n2 + 37/96*n3 -    1/360*n4 -   81/512*n5 +    96199/604800*n6,
                    1/48*n2 +  1/15*n3 - 437/1440*n4 +   46/105*n5 - 1118711/3870720*n6,
                    17/480*n3 -   37/840*n4 - 209/4480*n5 +      5569/90720*n6,
                    4397/161280*n4 -   11/504*n5 -  830251/7257600*n6,
                    4583/161280*n5 -  108847/3991680*n6,
                    20648693/638668800*n6 ];
        
        var xiPrime = xi;
        for j in 1...6 {
            let doubleJ = Double(j);
            xiPrime -= beta[j] * sin(2*doubleJ*xi) * cosh(2*doubleJ*eta);
        }
        
        var etaPrime = eta;
        for j in 1...6 {
            let doubleJ = Double(j);
            etaPrime -= beta[j] * cos(2*doubleJ*xi) * sinh(2*doubleJ*eta);
        }
        
        let sinhetaPrime = sinh(etaPrime);
        let sinxiPrime = sin(xiPrime), cosxiPrime = cos(xiPrime);

        let tauPrime = sinxiPrime / sqrt(sinhetaPrime*sinhetaPrime + cosxiPrime*cosxiPrime);

        var deltataui: Double = Double.greatestFiniteMagnitude;
        var taui = tauPrime;
        repeat {
            let sigmai = sinh(e*atanh(e*taui/sqrt(1+taui*taui)));
            let tauiPrime = taui * sqrt(1+sigmai*sigmai) - sigmai * sqrt(1+taui*taui);
            deltataui = (tauPrime - tauiPrime)/sqrt(1+tauiPrime*tauiPrime)
            * (1 + (1-e*e)*taui*taui) / ((1-e*e)*sqrt(1+taui*taui));
            taui += deltataui;
        } while (abs(deltataui) > 1e-12); // using IEEE 754 deltataui -> 0 after 2-3 iterations
        // note relatively large convergence test as deltataui toggles on ±1.12e-16 for eg 31 N 400000 5000000
        let tau = taui;

        let phi = atan(tau);

        var lambda = atan2(sinhetaPrime, cosxiPrime);

        // ---- convergence: Karney 2011 Eq 26, 27
        
        var p = 1.0;
        for j in 1...6 {
            let doubleJ = Double(j);
            p -= 2*doubleJ*beta[j] * cos(2*doubleJ*xi) * cosh(2*doubleJ*eta);
        }
        var q = 0.0;
        for j in 1...6 {
            let doubleJ = Double(j);
            q += 2*doubleJ*beta[j] * sin(2*doubleJ*xi) * sinh(2*doubleJ*eta);
        }

        // ------------
        
        let lambda0 = ((Double(zone)-1)*6 - 180 + 3).toRadians; // longitude of central meridian
        lambda += lambda0; // move lambda from zonal to global coordinates
        
        // round to reasonable precision
        let lat = phi.degrees.roundTo(places: 14) // nm precision (1nm = 10^-14°)
        let lon = lambda.degrees.roundTo(places: 14) // (strictly lat rounding should be phi⋅cosphi!)
        return GridPoint.degrees(lon, lat)
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
    public static func fromOriginal(_ point: GridPoint, _ zone: Int, _ hemisphere: Hemisphere) -> UTM {

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
     * Code from: https://www.movable-type.co.uk/scripts/latlong-utm-mgrs.html translated into swift
     * Converts latitude/longitude to UTM coordinate.
     *
     * Implements Karney’s method, using Krüger series to order n⁶, giving results accurate to 5nm
     * for distances up to 3900km from the central meridian.
     *
     * @param   {number} [zoneOverride] - Use specified zone rather than zone within which point lies;
     *          note overriding the UTM zone has the potential to result in negative eastings, and
     *          perverse results within Norway/Svalbard exceptions.
     * @returns {Utm} UTM coordinate.
     * @throws  {TypeError} Latitude outside UTM limits.
     *
     * @example
     *   const latlong = new LatLon(48.8582, 2.2945);
     *   const utmCoord = latlong.toUtm(); // 31 N 448252 5411933
     */
    public static func from(_ point: GridPoint, _ zoneOverride: Int, _ hemisphere: Hemisphere) -> UTM {
        
        let pointDegrees = point.toDegrees()
        
        let latitude = pointDegrees.latitude
        let longitude = pointDegrees.longitude
        
        let falseEasting = 500000.0, falseNorthing = 10000000.0;

        var zone = floor((longitude+180)/6) + 1; // longitudinal zone
        var lambda0 = ((zone-1)*6 - 180 + 3).toRadians; // longitude of central meridian
        
        // ---- handle Norway/Svalbard exceptions
        // grid zones are 8° tall; 0°N is offset 10 into latitude bands array
        let mgrsLatBands = ["C","D","E","F","G","H","J","K","L","M","N","P","Q","R","S","T","U","V","W","X","X"]; // X is repeated for 80-84°N
        let latBand = mgrsLatBands[Int(floor(latitude/8+10))];
        // adjust zone & central meridian for Norway
        if (zone == 31 && latBand == "V" && longitude >= 3) { zone += 1; lambda0 += (6).toRadians; }
        // adjust zone & central meridian for Svalbard
        if (zone==32 && latBand=="X" && longitude <  9) { zone -= 1; lambda0 -= (6).toRadians; }
        if (zone==32 && latBand=="X" && longitude >= 9) { zone += 1; lambda0 += (6).toRadians; }
        if (zone==34 && latBand=="X" && longitude < 21) { zone -= 1; lambda0 -= (6).toRadians; }
        if (zone==34 && latBand=="X" && longitude >= 21) { zone += 1; lambda0 += (6).toRadians; }
        if (zone==36 && latBand=="X" && longitude < 33) { zone -= 1; lambda0 -= (6).toRadians; }
        if (zone==36 && latBand=="X" && longitude >= 33) { zone += 1; lambda0 += (6).toRadians; }

        let phi = latitude.toRadians;      // latitude ± from equator
        let lambda = longitude.toRadians - lambda0; // longitude ± from central meridian
        
        let a = 6_378_137.0
        let f = 1.0 / 298.257223563
        
        let k0 = 0.9996; // UTM scale on the central meridian

        // ---- easting, northing: Karney 2011 Eq 7-14, 29, 35:
        
        let e = sqrt(f*(2-f)); // eccentricity
        let n = f / (2 - f);        // 3rd flattening
        let n2 = n*n, n3 = n*n2, n4 = n*n3, n5 = n*n4, n6 = n*n5;

        let coslambda = cos(lambda)
        let sinlambda = sin(lambda)

        let tau = tan(phi); // tau ≡ tanphi, tauʹ ≡ tanphiʹ; prime (ʹ) indicates angles on the conformal sphere
        let sigma = sinh(e*atanh(e*tau/sqrt(1+tau*tau)));

        let tauPrime = tau*sqrt(1+sigma*sigma) - sigma*sqrt(1+tau*tau);

        let xiPrime = atan2(tauPrime, coslambda);
        let etaPrime = asinh(sinlambda / sqrt(tauPrime*tauPrime + coslambda*coslambda));

        let A = a/(1+n) * (1 + 1/4*n2 + 1/64*n4 + 1/256*n6); // 2πA is the circumference of a meridian

        let alpha: [Double] = [ Double(0), // note α is one-based array (6th order Krüger expressions)
                          Double(1/2*n - 2/3*n2 + 5/16*n3 +   41/180*n4 -     127/288*n5 +      7891/37800*n6),
                          Double(13/48*n2 -  3/5*n3 + 557/1440*n4 +     281/630*n5 - 1983433/1935360*n6),
                          Double(61/240*n3 -  103/140*n4 + 15061/26880*n5 +   167603/181440*n6),
                          Double(49561/161280*n4 -     179/168*n5 + 6601661/7257600*n6),
                          Double(34729/80640*n5 - 3418889/1995840*n6),
                          Double(212378941/319334400*n6) ];
        
        var xi = xiPrime;
        for j in 1...6 {
            let doubleJ = Double(j);
            xi += alpha[j] * sin(2.0*doubleJ*xiPrime) * cosh(2.0*doubleJ*etaPrime);
        }
        
        var eta = etaPrime;
        for j in 1...6 {
            let doubleJ = Double(j);
            eta += alpha[j] * cos(2*doubleJ*xiPrime) * sinh(2*doubleJ*etaPrime);
        }
        
        var x = k0 * A * eta;
        var y = k0 * A * xi;

        // ---- convergence: Karney 2011 Eq 23, 24
        
        var pPrime = 1.0;
        for j in 1...6 {
            let doubleJ = Double(j);
            pPrime += 2*doubleJ*alpha[j] * cos(2*doubleJ*xiPrime) * cosh(2*doubleJ*etaPrime);
        }
        var qPrime = 0.0;
        for j in 1...6 {
            let doubleJ = Double(j);
            qPrime += 2*doubleJ*alpha[j] * sin(2*doubleJ*xiPrime) * sinh(2*doubleJ*etaPrime);
        }

        // ------------
        
        // shift x/y to false origins
        x = x + falseEasting;             // make x relative to false easting
        if (y < 0) {
            y = y + falseNorthing; // make y in southern hemisphere relative to false northing
        }
        
        return UTM(Int(zone), hemisphere, x, y)
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

extension Double {
    var toRadians: Double { return self * .pi / 180 }
    
    var degrees: Double {
        // The formula is: Radians = Degrees * pi / 180
        return self * 180 / .pi
    }
    
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
