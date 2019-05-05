//
//  GeoJSON.swift
//  GeoJSON
//
//  Created by Adolfo Martinelli on 10/4/16.
//  Copyright © 2016 AirMap, Inc. All rights reserved.
//

import Foundation
import CoreLocation

public typealias GeoJSONDictionary = [AnyHashable: Any]

public protocol GeoJSONConvertible {
	init?(dictionary: GeoJSONDictionary)
	func geoJSONRepresentation() -> GeoJSONDictionary
}

public protocol CoordinateConvertible {
	associatedtype CoordinateRepresentationType
	init?(coordinates: CoordinateRepresentationType)
	func coordinateRepresentation() -> CoordinateRepresentationType
}

public protocol GeometryConvertible {
	associatedtype GeometryType 
	var geometry: GeometryType { get set }
	init(geometry: GeometryType)
}

public protocol Feature: GeoJSONConvertible, CoordinateConvertible, GeometryConvertible {}

extension Feature {
	public init?(dictionary: GeoJSONDictionary) {
		guard let coordinates = (dictionary["geometry"] as? [AnyHashable: Any])?["coordinates"] as? CoordinateRepresentationType else { return nil }
		self.init(coordinates: coordinates)
	}
}

open class Point: Feature {
	
	public typealias GeometryType = CLLocationCoordinate2D
	public typealias CoordinateRepresentationType = [Double]
	
	open var geometry: CLLocationCoordinate2D
	
	public required init(geometry: CLLocationCoordinate2D) {
		self.geometry = geometry
	}
	
	public required init?(coordinates: CoordinateRepresentationType) {
		guard let position = CLLocationCoordinate2D(coordinates: coordinates) else { return nil }
		geometry = position
	}
	
	open func coordinateRepresentation() -> CoordinateRepresentationType {
		return geometry.geoJSONRepresentation
	}
}

open class LineString: Feature {
	
	public typealias GeometryType = [CLLocationCoordinate2D]
	public typealias CoordinateRepresentationType = [[Double]]
	
	open var geometry: [CLLocationCoordinate2D]

	public required init(geometry: [CLLocationCoordinate2D]) {
		self.geometry = geometry
	}

	public required init?(coordinates: CoordinateRepresentationType) {
		guard let positions = coordinates.map(CLLocationCoordinate2D.init) as? [CLLocationCoordinate2D]
		else { return nil }
		geometry = positions
	}
	
	open func coordinateRepresentation() -> CoordinateRepresentationType {
		return geometry.map { $0.geoJSONRepresentation }
	}
}

open class Polygon: Feature {
	
	public typealias GeometryType = [[CLLocationCoordinate2D]]
	public typealias CoordinateRepresentationType = [[[Double]]]
	
	open var geometry: [[CLLocationCoordinate2D]]

	public required init(geometry: [[CLLocationCoordinate2D]]) {
		self.geometry = geometry
	}

	public required init?(coordinates: CoordinateRepresentationType) {
		guard let linearRings = coordinates.map({ $0.compactMap(CLLocationCoordinate2D.init) }) as GeometryType? else { return nil }
		for linearRing in linearRings {
			guard linearRing.first == linearRing.last else { return nil }
		}
		self.geometry = linearRings
	}
	
	open func coordinateRepresentation() -> CoordinateRepresentationType {
		return geometry.map { $0.map { $0.geoJSONRepresentation } }
	}
}

public typealias MultiPoint = Multi<Point>

public typealias MultiLineString = Multi<LineString>

public typealias MultiPolygon = Multi<Polygon>

open class Multi<FeatureType: Feature> {
	
	open var features = [FeatureType]()
	
	public typealias GeometryType = [FeatureType.GeometryType]
	public typealias CoordinateRepresentationType = [FeatureType.CoordinateRepresentationType]
	
	open var geometry: GeometryType!
	
	public required init() {}
	
	public required init?(coordinates: CoordinateRepresentationType) {
		let features = coordinates.compactMap { (coords: FeatureType.CoordinateRepresentationType) in
			FeatureType(coordinates: coords)
		}
		self.features = features
		self.geometry = features.map { $0.geometry }
	}
	
	open var coordinateRepresentation: CoordinateRepresentationType {
		return features.map { $0.coordinateRepresentation() }
	}
	
}

open class FeatureCollection: GeoJSONConvertible {
	
	open var features: [GeoJSONConvertible]
	
	public required init(features: [GeoJSONConvertible]) {
		self.features = features
	}
	
	public required init?(dictionary: GeoJSONDictionary) {

		let geoJSONfeatures = dictionary["features"] as? [GeoJSONDictionary]

		self.features = geoJSONfeatures?
			.compactMap { feature in
				let type = (feature["geometry"] as? [AnyHashable: Any])?["type"] as! String
				switch type {
				case "Point":       return Point(dictionary: feature)
				case "Polygon":     return Polygon(dictionary: feature)
				case "LineString":  return LineString(dictionary: feature)
				default:
					print("GeoJSON type", type, "not implemented!")
					return nil
				}
		} ?? []
	}
	
	open func geoJSONRepresentation() -> GeoJSONDictionary {
		return [
			"type": "FeatureCollection",
			"features": features.map { $0.geoJSONRepresentation() },
			"properties": NSNull()
		]
	}
}

extension Feature {
	
	public func geoJSONRepresentation() -> GeoJSONDictionary {
		return [
			"type": "Feature",
			"geometry": [
				"type": String(describing: type(of: self)),
				"coordinates": coordinateRepresentation() as AnyObject,
				"properties": NSNull()
			],
			"properties": NSNull()
		]
	}
}

extension CLLocationCoordinate2D: Equatable {
	
	init?(coordinates: [Double]) {
		guard coordinates.count == 2 else { return nil }
		self.init(latitude: coordinates[1], longitude: coordinates[0])
	}
	
	var geoJSONRepresentation: [Double] {
		return [longitude, latitude]
	}
}

public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
	return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

public func +(lhs: FeatureCollection, rhs: FeatureCollection) -> FeatureCollection {
	return FeatureCollection(features: lhs.features+rhs.features)
}

