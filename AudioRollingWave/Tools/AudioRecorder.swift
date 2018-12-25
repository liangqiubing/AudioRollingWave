//
//  AudioRecorder
//
//  Created by 梁秋炳 on 2017/4/21.
//  Copyright © 2017年 梁秋炳. All rights reserved.
//

import UIKit
import AVFoundation

class AudioRecorder: NSObject {
    @objc static let AudioRecorderDidFinishRecordingNotify = Notification.Name("AudioRecorderDidFinishRecordingNotify")

    @objc static let shared = AudioRecorder()
    
    @objc var recorder:AVAudioRecorder?
    
    override init()  {
        super.init()
        
        let recorderSession = AVAudioSession.sharedInstance()
        
        do {
            try recorderSession.setCategory(AVAudioSessionCategoryPlayAndRecord,with:.defaultToSpeaker)
            try recorderSession.setActive(true)
            
            recorderSession.requestRecordPermission({ (allowed:Bool) in
                if allowed{
                    
                }else{
                    
                }
            })
            
        } catch  {
            
        }
    }

    @objc func record(fileName:String){
                
        let url = getUserPath().appendingPathComponent(fileName)
        let audioURL = URL(fileURLWithPath: url.path)
        let settings:[String:Any] = [
            AVFormatIDKey:NSNumber(value: kAudioFormatMPEG4AAC),
//            AVEncoderAudioQualityKey:AVAudioQuality.high.rawValue,
//            AVEncoderBitRateKey:12000.0,
            AVNumberOfChannelsKey:1,
            AVSampleRateKey:44100.0
        ]
        
        do {
            recorder = try AVAudioRecorder(url: audioURL, settings: settings)
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.prepareToRecord()
            recorder?.record()
            
        } catch {
        }
        
    }
    
    @objc func resumeRecording() {
        recorder?.record()
    }
    
    @objc func finishRecording() {
        recorder?.stop()
    }
    
    @objc func pauseRecording() {
        recorder?.pause()
    }
    
    @objc func getUserPath() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
}

extension AudioRecorder:AVAudioRecorderDelegate{

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        NotificationCenter.default.post(name: AudioRecorder.AudioRecorderDidFinishRecordingNotify, object: nil)
    }
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
}

