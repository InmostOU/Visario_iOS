//
//  SampleHandler.swift
//  Visario_UploadBroadcastExtension
//
//  Created by Konstantin Deulin on 29.09.2021.
//

import ReplayKit
import AmazonChimeSDK

class SampleHandler: RPBroadcastSampleHandler {
    
    private var userDefaultsObserver: NSKeyValueObservation?
    private let logger = ConsoleLogger(name: "UploadBroadcastExtension")
    private var currentMeetingSession: MeetingSession?
    
    private lazy var replayKitSource: ReplayKitSource = { return ReplayKitSource(logger: logger) }()
    
    private lazy var contentShareSource: ContentShareSource = {
        let source = ContentShareSource()
        source.videoSource = replayKitSource
        return source
    }()
    
    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {        
        guard let config = recreatMeetingSessionConfig() else {
            logger.error(msg: "Unable to recreate MeetingSessionConfiguration from Broadcast Extension")
            finishBroadcastWithError(NSError(domain: "AmazonChimeSDKDemoBroadcast", code: 0))
            return
        }
        currentMeetingSession = DefaultMeetingSession(configuration: config, logger: logger)
        currentMeetingSession?.audioVideo.startContentShare(source: contentShareSource)
        
        guard let appGroupUserDefaults = UserDefaults(suiteName: "group.com.Visario-iOS") else {
            print("App Group User Defaults not found")
            return
        }
        userDefaultsObserver = appGroupUserDefaults.observe(\.demoMeetingId,
                                                             options: [.new, .old]) { [weak self] (_, _) in
            guard let self = self else { return }
            self.finishBroadcastWithError(NSError(domain: "AmazonChimeSDKDemoBroadcast", code: 0))
        }
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        replayKitSource.stop()
        currentMeetingSession?.audioVideo.stopContentShare()
        userDefaultsObserver?.invalidate()
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        replayKitSource.processSampleBuffer(sampleBuffer: sampleBuffer, type: sampleBufferType)
    }
    
    func recreatMeetingSessionConfig() -> MeetingSessionConfiguration? {
        guard let appGroupUserDefaults = UserDefaults(suiteName: "group.com.Visario-iOS") else {
            logger.error(msg: "App Group User Defaults not found")
            return nil
        }
        let decoder = JSONDecoder()
        if let meetingId = appGroupUserDefaults.demoMeetingId,
           let credentialsData = appGroupUserDefaults.demoMeetingCredentials,
           let urlsData = appGroupUserDefaults.demoMeetingUrls,
           let credentials = try? decoder.decode(MeetingSessionCredentials.self, from: credentialsData),
           let urls = try? decoder.decode(MeetingSessionURLs.self, from: urlsData) {
            
            return MeetingSessionConfiguration(meetingId: meetingId,
                                               credentials: credentials,
                                               urls: urls,
                                               urlRewriter: URLRewriterUtils.defaultUrlRewriter)
        }
        return nil
    }
}

let userDefaultsKeyMeetingId = "demoMeetingId"
let userDefaultsKeyCredentials = "demoMeetingCredentials"
let userDefaultsKeyUrls = "demoMeetingUrls"

extension UserDefaults {
    
    @objc dynamic var demoMeetingId: String? {
        return string(forKey: userDefaultsKeyMeetingId)
    }
    @objc dynamic var demoMeetingCredentials: Data? {
        return object(forKey: userDefaultsKeyCredentials) as? Data
    }
    @objc dynamic var demoMeetingUrls: Data? {
        return object(forKey: userDefaultsKeyUrls) as? Data
    }
}
