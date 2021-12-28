//
//  MeetingAPIService.swift
//  Visario_iOS
//
//  Created by Konstantin Deulin on 23.09.2021.
//

import Moya

final class MeetingAPIService {
    
    typealias VoidCallback = (Result<Void, Error>) -> Void
    typealias ResponseMeetingCallback = (Result<CreateMeetingResponseModel, Error>) -> Void
    
    // MARK: - Properties
    
    let meetingsProvider = MoyaProvider<MeetingAPI>()
    
    // MARK: - Methods
    
    func createMeeting(callback: @escaping ResponseMeetingCallback) {
        meetingsProvider.request(.createMeeting) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let meetingResponse = try JSONDecoder().decode(CreateMeetingResponseModel.self, from: response.data)
                    callback(.success(meetingResponse))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getMeeting(meetingId: String, callback: @escaping ResponseMeetingCallback) {
        meetingsProvider.request(.getMeeting(meetingId: meetingId)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let attendeeResponse = try JSONDecoder().decode(CreateMeetingResponseModel.self, from: response.data)
                    callback(.success(attendeeResponse))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func getUserInfoByUserId(meetingId: String, userId: String, callback: @escaping (Result<UserInfoResponseModel, Error>) -> Void) {
        meetingsProvider.request(.getUserInfoByUserId(meetingId: meetingId, userId: userId)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                do {
                    let userInfo = try JSONDecoder().decode(UserInfoResponseModel.self, from: response.data)
                    callback(.success(userInfo))
                } catch {
                    callback(.failure(error))
                }
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
    
    func deleteAttendee(meetingId: String, userId: String, callback: @escaping VoidCallback) {
        meetingsProvider.request(.deleteAttendee(meetingId: meetingId, userId: userId)) { response in
            switch response {
            case .success(let response):
                guard response.statusCode == 200 else {
                    callback(.failure(NetworkError.statusCode))
                    return
                }
                callback(.success(()))
            case .failure(let error):
                callback(.failure(error))
            }
        }
    }
}


