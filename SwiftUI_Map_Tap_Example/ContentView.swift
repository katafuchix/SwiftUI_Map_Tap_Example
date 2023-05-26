//
//  ContentView.swift
//  SwiftUI_Map_Tap_Example
//
//  Created by cano on 2023/05/26.
//

import SwiftUI
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct ContentView: View {
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 35.70231371049, longitude: 139.58032280677), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    @State var longPressLocation = CGPoint.zero
    @State var customLocation = MapLocation(latitude: 0, longitude: 0)
    
    var body: some View {
        GeometryReader { proxy in
            Map(coordinateRegion: $region,
                annotationItems: [customLocation],
                annotationContent: { location in
                MapMarker(coordinate: location.coordinate, tint: .red)
            })
            .gesture(LongPressGesture(
                minimumDuration: 0.25)
                .sequenced(before: DragGesture(
                    minimumDistance: 0,
                    coordinateSpace: .local))
                    .onEnded { value in
                        switch value {
                        case .second(true, let drag):
                            longPressLocation = drag?.location ?? .zero
                            print(longPressLocation)
                            customLocation = convertTap(
                                                            at: longPressLocation,
                                                            for: proxy.size)
                        default:
                            break
                        }
                    })
            .highPriorityGesture(DragGesture(minimumDistance: 10)) //ドラッグ優先
        }
    }
    
    // タップ位置を緯度経度に変換
    func convertTap(at point: CGPoint, for mapSize: CGSize) -> MapLocation {
        let lat = self.region.center.latitude
        let lon = self.region.center.longitude
        
        // 地図の中心
        let mapCenter = CGPoint(x: mapSize.width/2, y: mapSize.height/2)
        
        // X位置のずれ具合
        let xValue = (point.x - mapCenter.x) / mapCenter.x
        let xSpan = xValue * region.span.longitudeDelta/2
        
        // Y位置のずれ具合
        let yValue = (point.y - mapCenter.y) / mapCenter.y
        let ySpan = yValue * region.span.latitudeDelta/2
        
        // ずれ具合から緯度経度を算出
        return MapLocation(latitude: lat - ySpan, longitude: lon + xSpan)
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
