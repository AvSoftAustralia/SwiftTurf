//
//  SwiftTurf.swift
//  SwiftTurf
//
//  Created by Adolfo Martinelli on 9/13/16.
//  Copyright (c) 2016 AirMap, Inc. All rights reserved.
//

import JavaScriptCore

final public class SwiftTurf {

	private static let sharedInstance = SwiftTurf()
	
	private let context = JSContext()
	
	public enum Units: String {
		case Meters     = "meters"
		case Kilometers = "kilometers"
		case Feet       = "feet"
		case Miles      = "miles"
		case Degrees    = "degrees"
	}
	
	private init() {

		let path = Bundle(for: SwiftTurf.self).path(forResource: "bundle", ofType: "js")!
		var js = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
		
		// Make browserify work
		js = "var window = this; \(js)"
		_ = context?.evaluateScript(js)

		context?.exceptionHandler = { context, exception in
			print(exception as Any)
		}
	}
	
	/// Calculates a buffer for input features for a given radius. Units supported are meters, kilometers, feet, miles, and degrees.
	///
	/// - parameter feature:  input to be buffered
	/// - parameter distance: distance to draw the buffer
	/// - parameter units: .Meters, .Kilometers, .Feet, .Miles, or .Degrees
	///
	/// - returns: Polygon?
	open static func buffer<G: GeoJSONConvertible>(_ feature: G, distance: Double, units: Units = .Meters) -> Polygon? {
		
		let bufferJs = sharedInstance.context?.objectForKeyedSubscript("buffer")!
		let args: [AnyObject] = [feature.geoJSONRepresentation() as AnyObject, distance as AnyObject, units.rawValue as AnyObject, 90 as AnyObject]
		
		if let bufferedGeoJSON = bufferJs?.call(withArguments: args)?.toDictionary() {
			return Polygon(dictionary: bufferedGeoJSON)
		} else {
			return nil
		}
	}
	
	/// Takes a Polygon and returns Points at all self-intersections.
	///
	/// - parameter feature: input polygon
	///
	/// - returns: FeatureCollection?
	open static func kinks(_ feature: Polygon) -> FeatureCollection? {
		
		let kinksJs = sharedInstance.context?.objectForKeyedSubscript("kinks")!
		let args: [AnyObject] = [feature.geoJSONRepresentation() as AnyObject]
		
		if let kinks = kinksJs?.call(withArguments: args)?.toDictionary() {
			return FeatureCollection(dictionary: kinks)
		} else {
			return nil
		}
	}
	
//	public static func union(feature: FeatureCollection) -> Polygon? {
//		
//		let unionFunction = sharedInstance.conttext.objectForKeyedSubscript("union")!
//		
//		let polygons = feature.features
//			.flatMap { $0 as? Polygon }
//			.flatMap { buffer($0, distance: 50, units: .Meters) }
//		
//		guard polygons.count != 0 else { return nil }
//		guard polygons.count >= 2 else { return polygons.first }
//		
//		var unionedPolygon = polygons.first
//		
//		for (index, polygon) in polygons.enumerate() {
//			if index == 0 { continue }
//			let polygonsToUnion = [unionedPolygon!.geoJSONRepresentation(), polygon.geoJSONRepresentation()]
//			if let unionResult = unionFunction.callWithArguments(	polygonsToUnion)!.toDictionary() {
//				unionedPolygon = Polygon(dictionary: unionResult)
//			}
//		}
//		return unionedPolygon
//	}
	
//	public static func explode(feature: GeoJSONConvertible) -> FeatureCollection? {
//		
//		let explodeFunction = sharedInstance.conttext.objectForKeyedSubscript("explode")!
//		if let points = explodeFunction.callWithArguments([feature.geoJSONRepresentation()])?.toDictionary() {
//			return FeatureCollection(dictionary: points)
//		} else {
//			return nil
//		}
//	}
	
//	public static func concave(points: FeatureCollection, maxEdge: Int, units: Units) -> Polygon? {
//		
//		let concaveFunction = sharedInstance.conttext.objectForKeyedSubscript("concave")!
//		let result = concaveFunction.callWithArguments([points.geoJSONRepresentation(), maxEdge, units.rawValue])
//		
//		if let concave = result?.toDictionary() {
//			return Polygon(dictionary: concave)
//		} else {
//			return nil
//		}
//	}

	public static func convex(points: FeatureCollection) -> Polygon? {
		
		let convexFunction = sharedInstance.conttext.objectForKeyedSubscript("convex")!
		let result = convexFunction.callWithArguments([points.geoJSONRepresentation()])
		
		if let convex = result?.toDictionary() {
			return Polygon(dictionary: convex)
		} else {
			return nil
		}
	}

//	public static func tesselate(feature: GeoJSONConvertible) -> FeatureCollection? {
//	
//		let tesselateFunction = sharedInstance.conttext.objectForKeyedSubscript("tesselate")!
//		let tesselatedPolygons = tesselateFunction.callWithArguments([feature.geoJSONRepresentation()])!
//		let geoJSON = tesselatedPolygons.toDictionary()!
//		let featureCollection = FeatureCollection(dictionary: geoJSON)
//		
//		return featureCollection
//	}
	
}
