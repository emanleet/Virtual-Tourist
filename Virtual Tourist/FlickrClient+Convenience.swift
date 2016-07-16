//
//  FlickrClient+Convenience.swift
//  Virtual Tourist
//
//  Created by Emmanuoel Eldridge on 7/14/16.
//  Copyright © 2016 Emmanuoel Haroutunian. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    func searchPhotoURLsWithLocation(latitude: Double, longitude: Double, completionHandlerForSearchPhotos: (result: AnyObject?, error: NSError?)->Void) {
        let bbox = bboxCoordinate.sharedInstance.makeBbox(latitude, longitude: longitude)
        let scheme = FlickrClient.Constants.Scheme
        let host = FlickrClient.Constants.Host
        let path = FlickrClient.Constants.Path
        let parameters = [FlickrClient.ParameterKeys.APIKey: FlickrClient.ParameterValues.FlickrAPI,
                          FlickrClient.ParameterKeys.Format: FlickrClient.ParameterValues.JSONFormat,
                          FlickrClient.ParameterKeys.Method: FlickrClient.ParameterValues.PhotoSearchMethod,
                          FlickrClient.ParameterKeys.NoJSONCallBack: FlickrClient.ParameterValues.NoJSONCallBack,
                          FlickrClient.ParameterKeys.Extras: ParameterValues.imageURLMedium,
                          FlickrClient.ParameterKeys.Bbox: bbox]
        
        let url = buildURLWithComponents(scheme, host: host, path: path, parameters: parameters)
        
        taskForGETMethod(url) { (result, error) in
            if let error = error {
                completionHandlerForSearchPhotos(result: nil, error: error)
            } else {
                if let result = result as? [String: AnyObject] {
                    guard let photosDict = result[FlickrClient.ResponseKeys.Photos] as? [String: AnyObject],
                        let photosArray = photosDict[FlickrClient.ResponseKeys.Photo] as? [[String: AnyObject]] else {
                            let userInfo = ["NSUnderlyingErrorKey": "Could not access photos array"]
                            let error = NSError(domain: "searchPhotosWithLocation", code: 10, userInfo: userInfo)
                            completionHandlerForSearchPhotos(result: nil, error: error)
                            return
                    }
                    
                    var photoURLs = [NSURL]()
                    for photo in photosArray {
                        if let urlString = photo[FlickrClient.ResponseKeys.URL] as? String,
                            let url = NSURL(string: urlString) {
                            photoURLs.append(url)
                        } else {
                            print("No url found for photo")
                        }
                    }
                    completionHandlerForSearchPhotos(result: photoURLs, error: nil)
                }
            }
        }
    }
    
    func downloadDataFromURL(photoURLs: [NSURL], pin: Pin, completionHandler: (result: [NSData]?, error: NSError?)->Void) {
        let queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)
        dispatch_async(queue) {
            var dataForImages = [NSData]()
            for url in photoURLs {
                if let data = NSData(contentsOfURL: url) {
                    dataForImages.append(data)
                } else {
                    let userInfo = ["NSUnderlyingErrorKey": "Failed to access image data from url: \(url)"]
                    let error = NSError(domain: "downloadImages", code: 10, userInfo: userInfo)
                    completionHandler(result: nil, error: error)
                }
            }
            completionHandler(result: dataForImages, error: nil)
        }
    }
    
    func retrieveImageData(pin: Pin, completionHandler: (result: [NSData]?, error: NSError?)->Void) {
        searchPhotoURLsWithLocation(pin.latitude, longitude: pin.longitude) { (result, error) in
            if let error = error {
                print(error.userInfo["NSUnderlyingErrorKey"])
            } else if let result = result as? [NSURL] {
                self.downloadDataFromURL(result, pin: pin){ (result, error) in
                    if let error = error {
                        completionHandler(result: nil, error: error)
                    } else {
                        completionHandler(result: result, error: nil)
                    }
                    
                }
            }
            
        }
    }
    
}