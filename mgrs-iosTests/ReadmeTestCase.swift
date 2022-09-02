//
//  ReadmeTestCase.swift
//  mgrs-iosTests
//
//  Created by Brian Osborn on 8/22/22.
//

import XCTest
@testable import grid_ios
@testable import mgrs_ios
import MapKit

/**
 * README example tests
 */
class ReadmeTestCase: XCTestCase {

    /**
     * Test MGRS coordinates
     */
    func testCoordinates() {
        
        let mgrs = MGRS.parse("33XVG74594359")
        let point = mgrs.toPoint()
        let pointMeters = point.toMeters()
        let utm = mgrs.toUTM()
        let utmCoordinate = utm.description
        let point2 = utm.toPoint()

        let mgrs2 = MGRS.parse("33X VG 74596 43594")

        let latitude = 63.98862388
        let longitude = 29.06755082
        let point3 = GridPoint(longitude, latitude)
        let mgrs3 = MGRS.from(point3)
        let mgrsCoordinate = mgrs3.description
        let mgrsGZD = mgrs3.coordinate(GridType.GZD)
        let mgrs100k = mgrs3.coordinate(GridType.HUNDRED_KILOMETER)
        let mgrs10k = mgrs3.coordinate(GridType.TEN_KILOMETER)
        let mgrs1k = mgrs3.coordinate(GridType.KILOMETER)
        let mgrs100m = mgrs3.coordinate(GridType.HUNDRED_METER)
        let mgrs10m = mgrs3.coordinate(GridType.TEN_METER)
        let mgrs1m = mgrs3.coordinate(GridType.METER)

        let utm2 = UTM.from(point3)
        let mgrs4 = utm2.toMGRS()

        let utm3 = UTM.parse("18 N 585628 4511322")
        let mgrs5 = utm3.toMGRS()
        
    }
    
    /**
     * Test tile overlay
     */
    func testTileOverlay() {
        
        // let mapView: MKMapView = ...

        // Tile size determined from display density
        let tileOverlay = MGRSTileOverlay()

        // Manually specify tile size
        let tileOverlay2 = MGRSTileOverlay(512, 512)

        // GZD only grid
        let gzdTileOverlay = MGRSTileOverlay.createGZD()
        
        // Specified grids
        let customTileOverlay = MGRSTileOverlay(
                [GridType.GZD, GridType.HUNDRED_KILOMETER])

        //mapView.addOverlay(tileOverlay)
        
    }
    
    /**
     * Test tile provider options
     */
    func testOptions() {
        
        let tileOverlay = MGRSTileOverlay()

        let x = 8
        let y = 12
        let zoom = 5

        // Manually get a tile or draw the tile bitmap
        let tile = tileOverlay.tile(x, y, zoom)
        let tileImage = tileOverlay.drawTile(x, y, zoom)

        let latitude = 63.98862388
        let longitude = 29.06755082
        let locationCoordinate = CLLocationCoordinate2DMake(latitude, longitude)

        // MGRS Coordinates
        let mgrs = tileOverlay.mgrs(locationCoordinate)
        let coordinate = tileOverlay.coordinate(locationCoordinate)
        let zoomCoordinate = tileOverlay.coordinate(locationCoordinate, zoom)

        let mgrsGZD = tileOverlay.coordinate(locationCoordinate, GridType.GZD)
        let mgrs100k = tileOverlay.coordinate(locationCoordinate, GridType.HUNDRED_KILOMETER)
        let mgrs10k = tileOverlay.coordinate(locationCoordinate, GridType.TEN_KILOMETER)
        let mgrs1k = tileOverlay.coordinate(locationCoordinate, GridType.KILOMETER)
        let mgrs100m = tileOverlay.coordinate(locationCoordinate, GridType.HUNDRED_METER)
        let mgrs10m = tileOverlay.coordinate(locationCoordinate, GridType.TEN_METER)
        let mgrs1m = tileOverlay.coordinate(locationCoordinate, GridType.METER)
        
    }
    
    /**
     * Test custom grids
     */
    func testCustomGrids() {
        
        let grids = Grids()

        grids.setColor(GridType.GZD, UIColor.red)
        grids.setWidth(GridType.GZD, 5.0)

        grids.setLabelMinZoom(GridType.GZD, 3)
        grids.setLabelMaxZoom(GridType.GZD, 8)
        grids.setLabelTextSize(GridType.GZD, 32.0)

        grids.setMinZoom(GridType.HUNDRED_KILOMETER, 4)
        grids.setMaxZoom(GridType.HUNDRED_KILOMETER, 8)
        grids.setColor(GridType.HUNDRED_KILOMETER, UIColor.blue)

        grids.setLabelColor(GridType.HUNDRED_KILOMETER, UIColor.orange)
        grids.setLabelBuffer(GridType.HUNDRED_KILOMETER, 0.1)

        grids.setColor([GridType.TEN_KILOMETER, GridType.KILOMETER, GridType.HUNDRED_METER, GridType.TEN_METER], UIColor.darkGray)
        
        grids.disable(GridType.METER)
        
        grids.enableLabeler(GridTYpe.TEN_KILOMETER)
        
        let tileOverlay = MGRSTileOverlay(grids)

    }
    
    /**
     * Test draw tile template logic
     */
    func testDrawTile() {
        ReadmeTestCase.testDrawTile(GridTile(512, 512, 8, 12, 5))
    }
    
    /**
     * Test draw tile template logic
     *
     * @param tile
     *            grid tile
     */
    private static func testDrawTile(_ tile: GridTile) {
        
        // let tile: GridTile = ...
        
        let grids = Grids()

        let zoomGrids = grids.grids(tile.zoom)
        if zoomGrids.hasGrids() {

            let gridRange = GridZones.gridRange(tile.bounds)
            
            for grid in zoomGrids {

                // draw this grid for each zone
                for zone in gridRange {
                
                    let lines = grid.lines(tile, zone)
                    if lines != nil {
                        let pixelRange = zone.bounds.pixelRange(tile)
                        for line in lines! {
                            let pixel1 = line.point1.pixel(tile)
                            let pixel2 = line.point2.pixel(tile)
                            // Draw line
                        }
                    }

                    let labels = grid.labels(tile, zone)
                    if labels != nil {
                        for label in labels! {
                            let pixelRange = label.bounds.pixelRange(tile)
                            let centerPixel = label.center.pixel(tile)
                            // Draw label
                        }
                    }

                }
            }
        }
         
    }
    
}
