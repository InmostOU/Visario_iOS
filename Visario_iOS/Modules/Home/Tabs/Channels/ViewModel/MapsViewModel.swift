//
//  MapsViewModel.swift
//  Visario_iOS
//
//  Created by Vitaliy Butsan on 28.10.2021.
//

import MapKit

final class MapsViewModel {
    
    private(set) var placeMarks: [MKPlacemark] = []
    
    func search(by query: String, completion: @escaping(Result<Void, Error>) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        
        MKLocalSearch(request: request).start { [weak self] (response, error) in
            guard error == nil else {
                completion(.failure(error!))
                return
            }
            guard let self = self else { return }
            guard let result = response else { return }
            
            self.placeMarks = result.mapItems.map(\.placemark)
            completion(.success(()))
        }
    }
}
