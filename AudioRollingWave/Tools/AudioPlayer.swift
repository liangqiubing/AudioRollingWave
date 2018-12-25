//
//  AudioRecorder
//
//  Created by 梁秋炳 on 2017/4/21.
//  Copyright © 2017年 梁秋炳. All rights reserved.
//

import UIKit
import AVFoundation


class AudioPlayer: NSObject {
    @objc static let AudioPalyerDidFinishPlayingNotify = Notification.Name("AudioPalyerDidFinishPlayingNotify")

    @objc static let shared = AudioPlayer()
    
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
    
    @objc var player:AVAudioPlayer?
    
    @objc func play(fileName:String) {
        do {
            let url = AudioPlayer.audioFileInUserDoc(fileName)
            if FileManager.default.fileExists(atPath: url.path) {
                player  = try AVAudioPlayer(contentsOf:url)
            }else if let url = URL(string: fileName){
                player  = try AVAudioPlayer(data: Data(contentsOf: url))
            }
            player?.delegate = self
            player?.isMeteringEnabled = true
            player?.prepareToPlay()
            player?.play()
        } catch  {
            
        }
    }
    
    @objc func duration(fileName:String)->TimeInterval {
        do {
            let url = AudioPlayer.audioFileInUserDoc(fileName)
            if FileManager.default.fileExists(atPath: url.path) {
                player  = try AVAudioPlayer(contentsOf:url)
            }else if let url = URL(string: fileName){
                player  = try AVAudioPlayer(data: Data(contentsOf: url))
            }
            player?.prepareToPlay()
            player?.currentTime = player?.duration ?? 0.0
            player?.currentTime = 0.0
            return player?.duration ?? 0.0
        } catch  {
            
        }
        return 0;
    }
    
    @objc func finishPlaying() {
        player?.stop()
        NotificationCenter.default.post(name: AudioPlayer.AudioPalyerDidFinishPlayingNotify, object: nil)
    }
    
    @objc var isPlaying: Bool {
        return player?.isPlaying ?? false
    }
    
    @objc func deleteAudio(_ fileName:String) throws{
        try FileManager.default.removeItem(at: AudioPlayer.audioFileInUserDoc(fileName))
    }
    
    @objc static func audioFileInUserDoc(_ fileName:String) -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return url.appendingPathComponent(fileName)
    }
    
}

extension AudioPlayer:AVAudioPlayerDelegate{

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        NotificationCenter.default.post(name: AudioPlayer.AudioPalyerDidFinishPlayingNotify, object: nil)
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription ?? "")
    }
    
    
}
