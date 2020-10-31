//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Luk, Alex on 5/6/18.
//  Copyright © 2018 Udacity. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    private func getDefaultMethodParameters(latitude: Double, longitude: Double) -> [String : String] {
        return [
            FlickrConstants.ParameterKeys.Method: FlickrConstants.ParameterValues.SearchMethod,
            FlickrConstants.ParameterKeys.APIKey: FlickrConstants.ParameterValues.APIKey,
            FlickrConstants.ParameterKeys.BoundingBox: bboxString(latitude: latitude, longitude: longitude),
            FlickrConstants.ParameterKeys.SafeSearch: FlickrConstants.ParameterValues.UseSafeSearch,
            FlickrConstants.ParameterKeys.Extras: FlickrConstants.ParameterValues.MediumURL,
            FlickrConstants.ParameterKeys.Format: FlickrConstants.ParameterValues.ResponseFormat,
            FlickrConstants.ParameterKeys.NoJSONCallback: FlickrConstants.ParameterValues.DisableJSONCallback,
            FlickrConstants.ParameterKeys.PerPage: String(FlickrConstants.ParameterValues.PerPage)
        ]
    }
    
    func getResultsFromFlickr(pin:Pin, withPageNumber: Int,
        completionHandlerForGET: @escaping (_ result: [String:AnyObject]?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // get params and add page number
        var methodParameters = getDefaultMethodParameters(latitude: pin.latitude, longitude: pin.longitude);
        methodParameters[FlickrConstants.ParameterKeys.Page] = String(withPageNumber)
        
        // create session and request
        let session = URLSession.shared
        let request = URLRequest(url: flickrURLFromParameters(methodParameters as [String : AnyObject]))
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(_ error: String) {
                print(error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError(FlickrConstants.ErrorMessages.GenericError + (String(describing: error)))
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError(FlickrConstants.ErrorMessages.Not2xxError)
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError(FlickrConstants.ErrorMessages.NoData)
                return
            }
            
            // parse the data
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError(FlickrConstants.ErrorMessages.CouldNotParseJSON + String(describing: data))
                return
            }
            
            guard let stat = parsedResult[FlickrConstants.ResponseKeys.Status] as? String, stat == FlickrConstants.ResponseValues.OKStatus else {
                displayError(FlickrConstants.ErrorMessages.FlickrAPIError + String(describing:parsedResult))
                return
            }

            guard let photosDictionary = parsedResult[FlickrConstants.ResponseKeys.Photos] as? [String:AnyObject] else {
                displayError(FlickrConstants.ErrorMessages.CannotFindPhotosKey + String(describing:parsedResult))
                return
            }
            
            guard (photosDictionary[FlickrConstants.ResponseKeys.Total] as? String) != nil else {
                displayError(FlickrConstants.ErrorMessages.CannotFindTotalKey + String(describing:parsedResult))
                return
            }
            
            completionHandlerForGET(photosDictionary , nil)
        }
        
        // start the task!
        task.resume()
        return task
    }
    
    private func bboxString(latitude: Double, longitude: Double) -> String {
        // ensure bbox is bounded by minimum and maximums
        let minimumLon = max(longitude - FlickrConstants.APIProperties.SearchBBoxHalfWidth, FlickrConstants.APIProperties.SearchLonRange.0)
        let minimumLat = max(latitude - FlickrConstants.APIProperties.SearchBBoxHalfHeight, FlickrConstants.APIProperties.SearchLatRange.0)
        let maximumLon = min(longitude + FlickrConstants.APIProperties.SearchBBoxHalfWidth, FlickrConstants.APIProperties.SearchLonRange.1)
        let maximumLat = min(latitude + FlickrConstants.APIProperties.SearchBBoxHalfHeight, FlickrConstants.APIProperties.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }

    // MARK: Helper for Creating a URL from Parameters
    
    private func flickrURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = FlickrConstants.APIProperties.APIScheme
        components.host = FlickrConstants.APIProperties.APIHost
        components.path = FlickrConstants.APIProperties.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}
