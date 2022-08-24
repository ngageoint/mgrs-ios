//
//  GridZone.swift
//  mgrs-ios
//
//  Created by Brian Osborn on 8/23/22.
//

import Foundation
import grid_ios

/**
 * Grid Zone
 */
public class GridZone {
    
    /**
     * Longitudinal strip
     */
    public let strip: LongitudinalStrip
    
    /**
     * Latitude band
     */
    public let band: LatitudeBand
    
    /**
     * Bounds
     */
    public let bounds: Bounds
    
    /**
     * Constructor
     *
     * @param strip
     *            longitudinal strip
     * @param band
     *            latitude band
     */
    public init(_ strip: LongitudinalStrip, _ band: LatitudeBand) {
        self.strip = strip;
        self.band = band;
        self.bounds = Bounds.degrees(strip.west, band.south, strip.east, band.north)
    }
    
    // TODO
    
}
