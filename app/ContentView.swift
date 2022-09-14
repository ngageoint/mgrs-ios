//
//  ContentView.swift
//  app
//
//  Created by Brian Osborn on 8/22/22.
//

import SwiftUI
import MapKit
import mgrs_ios
import grid_ios

struct ContentView: View {

    let mapState = MapState()
    @ObservedObject var coordinate: Coordinate = Coordinate()
    @State private var isShowingSearch = false

    var body: some View {
        VStack {
            MapView(mapState, coordinate)
            HStack {
                Text(coordinate.mgrsLabel).font(.footnote)
                Spacer()
                Text(coordinate.wgs84Label).font(.footnote)
                Spacer()
                Text(coordinate.zoomLabel).font(.footnote)
                Button(action: {
                    withAnimation {
                        self.isShowingSearch.toggle()
                    }
                }) {
                    Image("search")
                        .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                }
                Menu {
                    Button("Muted Standard", action: { mapState.mapView.mapType = MKMapType.mutedStandard })
                    Button("Hybrid", action: { mapState.mapView.mapType = MKMapType.hybrid })
                    Button("Satellite", action: { mapState.mapView.mapType = MKMapType.satellite })
                    Button("Standard", action: { mapState.mapView.mapType = MKMapType.standard } )
                } label: {
                    Image("layers")
                        .renderingMode(Image.TemplateRenderingMode?.init(Image.TemplateRenderingMode.original))
                }
            }
            .padding()
            .textSelection(.enabled)
        }
        .textSearch(isShowing: $isShowingSearch, mapState: mapState)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class Coordinate: ObservableObject{
    @Published var mgrsLabel = ""
    @Published var wgs84Label = ""
    @Published var zoomLabel = ""
}

class MapState {

    let mapView = MKMapView()
    let tileOverlay: MGRSTileOverlay
    var searchMGRSResult: String?

    init() {
        let grids = Grids()
        grids.setLabelMinZoom(GridType.GZD, 3)
        tileOverlay = MGRSTileOverlay(grids)
    }

}

struct MapView: UIViewRepresentable {

    let mapState: MapState
    let coordinate: Coordinate

    init(_ mapState: MapState, _ coordinate: Coordinate) {
        self.mapState = mapState
        self.coordinate = coordinate
    }

    func makeUIView(context: Context) -> MKMapView {

        mapState.mapView.delegate = context.coordinator
        mapState.mapView.addOverlay(mapState.tileOverlay)

        // double tap recognizer has no action
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: nil)
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.numberOfTouchesRequired = 1
        mapState.mapView.addGestureRecognizer(doubleTapRecognizer)

        let singleTapGestureRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.singleTapGesture(tapGestureRecognizer:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.numberOfTouchesRequired = 1
        singleTapGestureRecognizer.delaysTouchesBegan = true
        singleTapGestureRecognizer.cancelsTouchesInView = true
        singleTapGestureRecognizer.delegate = context.coordinator
        singleTapGestureRecognizer.require(toFail: doubleTapRecognizer)
        mapState.mapView.addGestureRecognizer(singleTapGestureRecognizer)

        return mapState.mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {

    }

    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator(mapState, coordinate)
    }

}

class MapViewCoordinator: NSObject, MKMapViewDelegate, UIGestureRecognizerDelegate {

    let mapState: MapState
    let coordinate: Coordinate
    let formatter: NumberFormatter
    var centerAdded: Bool = false

    init(_ mapState: MapState, _ coordinate: Coordinate) {
        self.mapState = mapState
        self.coordinate = coordinate

        formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 5
    }

    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        addCenter(mapView)
    }

    func addCenter(_ uiView: MKMapView) {
        if !centerAdded && uiView.frame.size.height > 0 {
            let image = UIImageView(image: UIImage(named: "center")?.image(alpha: 0.25))
            image.isUserInteractionEnabled = false
            image.center = CGPoint(x: uiView.frame.size.width/2, y: uiView.frame.size.height/2)
            uiView.addSubview(image)
            centerAdded = true
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKTileOverlayRenderer(overlay: overlay)
        return renderer
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let zoom = TileUtils.currentZoom(mapView)
        var mgrs: String? = nil
        if mapState.searchMGRSResult != nil {
            mgrs = mapState.searchMGRSResult
            mapState.searchMGRSResult = nil
        } else {
            mgrs = mapState.tileOverlay.coordinate(center, Int(zoom))
        }
        DispatchQueue.main.async {
            self.coordinate.wgs84Label = self.formatter.string(from: center.longitude as NSNumber)! + "," + self.formatter.string(from: center.latitude as NSNumber)!
            self.coordinate.mgrsLabel = mgrs!
            self.coordinate.zoomLabel = String(format: "%.1f", trunc(zoom * 10) / 10)
        }
    }

    @objc func singleTapGesture(tapGestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer.state == .ended {
            self.mapTap(tapGestureRecognizer.location(in: mapState.mapView), tapGestureRecognizer)
        }
    }

    func mapTap(_ tapPoint:CGPoint, _ gesture: UITapGestureRecognizer) {
        let tapCoord = mapState.mapView.convert(tapPoint, toCoordinateFrom: mapState.mapView)
        mapState.mapView.setCenter(tapCoord, animated: true)
    }

}

/**
 * Search and move to the coordinate
 *
 * @param mapState map state
 * @param coordinate MGRS or WGS84 coordinate
 * @return true if search found coordinate, false if not
 */
private func search(_ mapState: MapState, _ coordinate: String) -> Bool {
    mapState.searchMGRSResult = nil
    var point: GridPoint? = nil
    var zoom: Int? = nil
    let currentZoom = TileUtils.currentZoom(mapState.mapView)
    let coord = coordinate.trimmingCharacters(in: .whitespacesAndNewlines)
    if MGRS.isMGRS(coord) {
        let mgrs = MGRS.parse(coordinate)
        let gridType = MGRS.precision(coordinate)
        point = mgrs.toPoint()
        mapState.searchMGRSResult = coordinate.uppercased()
        zoom = mgrsCoordinateZoom(mapState, gridType, currentZoom)
    } else {
        let parts = coordinate.components(separatedBy: ",")
        if parts.count == 2 {
            let lon = Double(parts[0].trimmingCharacters(in: .whitespacesAndNewlines))
            let lat = Double(parts[1].trimmingCharacters(in: .whitespacesAndNewlines))
            if lon != nil && lat != nil {
                point = GridPoint(lon!, lat!)
            }
        }
    }
    let found = point != nil ? true : false
    if found {
        let locationCoordinate = TileUtils.toCoordinate(point!)
        if mapState.searchMGRSResult == nil {
            mapState.searchMGRSResult = mapState.tileOverlay.coordinate(locationCoordinate, Int(currentZoom))
        }

        if zoom != nil {
            let region = TileUtils.coordinateRegion(locationCoordinate, Double(zoom!), mapState.mapView)
            mapState.mapView.setRegion(region, animated: true)
        } else {
            mapState.mapView.setCenter(locationCoordinate, animated: true)
        }

    }

    return found
}

/**
 * Get the MGRS coordinate zoom level
 *
 * @param mapState map state
 * @param gridType grid type precision
 * @param zoom     current zoom
 * @return zoom level or null
 */
private func mgrsCoordinateZoom(_ mapState: MapState, _ gridType: GridType, _ zoom: Double) -> Int? {
    var mgrsZoom: Int? = nil
    let grid = mapState.tileOverlay.grid(gridType)
    let minZoom = grid.linesMinZoom
    if minZoom != nil && zoom < Double(minZoom!) {
        mgrsZoom = minZoom
    } else {
        let maxZoom = grid.linesMaxZoom
        if maxZoom != nil && zoom >= Double(maxZoom!) + 1 {
            mgrsZoom = maxZoom
        }
    }
    return mgrsZoom
}

struct TextSearch<Presenting>: View where Presenting: View {

    @Binding var isShowing: Bool
    let mapState: MapState
    let presenting: Presenting
    @State var text = ""
    @State var searchAlert = false
    @State var searchAlertText = ""

    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            ZStack {
                self.presenting
                    .disabled(isShowing)
                VStack {
                    Text("Search Coordinate")
                    TextField("", text: self.$text)
                    Divider()
                    HStack {
                        Button(action: {
                            withAnimation {
                                self.isShowing.toggle()
                                self.text = ""
                            }
                        }) {
                            Text("Cancel")
                        }
                        Spacer()
                        Button(action: {
                            withAnimation {
                                self.isShowing.toggle()
                                if !search(mapState, self.text) {
                                    searchAlertText = self.text
                                    searchAlert.toggle()
                                }
                                self.text = ""
                            }
                        }) {
                            Text("Search")
                        }.alert(isPresented: $searchAlert, content: {
                            Alert(title: Text("Unsupported Coordinate:\n\(searchAlertText)"))
                        })
                    }
                }
                .padding()
                .background(Color.white)
                .frame(
                    width: deviceSize.size.width*0.7,
                    height: deviceSize.size.height*0.7
                )
                .shadow(radius: 1)
                .opacity(self.isShowing ? 1 : 0)
            }
        }
    }

}

extension UIImage {
    func image(alpha: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero, blendMode: .normal, alpha: alpha)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension View {
    func textSearch(isShowing: Binding<Bool>,
                        mapState: MapState) -> some View {
        TextSearch(isShowing: isShowing,
                       mapState: mapState,
                       presenting: self)
    }
}
