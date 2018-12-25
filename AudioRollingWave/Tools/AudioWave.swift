//
//  AudioWave.swift
//
//  Created by 梁秋炳 on 18/12/25.
//  Copyright © 2018年 梁秋炳. All rights reserved.
//

import Foundation
import UIKit
@IBDesignable
public class AudioWave: UIView {
    
    @IBInspectable  public  var waveColor: UIColor = UIColor.gray
    @IBInspectable  public  var xLineColor: UIColor = UIColor.clear
    @IBInspectable  public  var timePointColor: UIColor = UIColor.gray
    @IBInspectable  public  var showTimePoint: Bool = true

    //刷新频率,单位秒
    @IBInspectable public var intervalTime: Double = 1.0/60.0 {
        didSet {
            self.secondsInWidth = Int(floor(Double(self.bounds.size.width) / (self.sampleWidth / self.intervalTime)))
            //            self.setNeedsDisplay()
        }
        
    }
    //sampel宽度
    @IBInspectable public var sampleWidth: Double = 1.5 {
        didSet {
            self.sampleNum = Int(ceil(Double(self.bounds.size.width) / self.sampleWidth))
            self.secondsInWidth = Int(floor(Double(self.bounds.size.width) / (self.sampleWidth / self.intervalTime)))
            self.divisorSampleNum = Int(Double(self.sampleNum)*widthDivisor);
            //            self.setNeedsDisplay()
        }
    }
    @IBInspectable  public  var widthDivisor: Double = 0.75{
        didSet{
            self.divisorSampleNum = Int(Double(self.sampleNum)*widthDivisor);
        }
    }
    
    //分割线左边sampel个数
    public private(set) var divisorSampleNum = 0

    //sampel个数
    public private(set) var sampleNum = 0
    
    //轮训次数
    private var scheduledCount = 0
    //wave的数据源
    private var waveDataSource = [Double]()
    //刷新定时器
    public var displayLink : CADisplayLink?
    
    private var callback:((_ wave:AudioWave)->())?
    //起始位置时间
    private var beginTime = 0.0
    //起始打点时间
    private var beginTimePoint = 0
    //宽度里显示的完整秒数
    private var secondsInWidth = 0
    
    private let powerFactor = 40.0
    private var min = 0.0
    private var max = 0.0
    
    // MARK: - Life cycle
    deinit{
        self.displayLink?.invalidate()
        self.layer.removeAllAnimations()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public override var frame: CGRect{
        set{
            super.frame = newValue;
            self.commonInit()
        }
        get{
            return super.frame;
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.commonInit()
    }
    
    // Only override drawRect: if you perform custom drasampleWidthng.
    // An empty implementation adversely affects performance during animation.
    public override func draw(_ rect: CGRect) {
        //设置背景色
        self.backgroundColor!.setFill()
        UIRectFill(self.bounds);
        
        
        
        var timePoint = 0.0 + beginTime;
        let count = self.waveDataSource.count
        let countInSecnond = Int(1.0 / self.intervalTime)
        var timePointViewHiehgt:CGFloat = 30.0
        if self.showTimePoint == false {
            timePointViewHiehgt = 0.0
        }
        for i in 0 ..< scheduledCount{
            //draw wave
            if i < count{
                let wavePoint = CGFloat(self.waveDataSource[i])
                var height:CGFloat = 0.0
                height = ((wavePoint + 0) / 100.0) * (self.bounds.size.height - timePointViewHiehgt)
                let rect = CGRect(x: CGFloat(Double(i)*sampleWidth), y: (self.bounds.size.height + timePointViewHiehgt-height)/2.0 , width: CGFloat(sampleWidth), height: CGFloat(height));
                self.waveColor.setFill()
                UIRectFill(rect);
                
            }
            
            if self.showTimePoint == false{
                continue
            }
            let time = Double(i-divisorSampleNum) * self.intervalTime;
            if i > divisorSampleNum{
                self.beginTime =   timePoint - time
                self.beginTimePoint += 1
                break
            }
            var num = i;
            if i==divisorSampleNum {
                num = sampleNum;
            }
            
            for j in i...num{
                let time = Double(j-divisorSampleNum) * self.intervalTime;
                let timeSpace = Double(self.scheduledCount) * self.intervalTime - Double(self.divisorSampleNum)*intervalTime
                if( (j + self.beginTimePoint) % countInSecnond == 0&&(time+timeSpace)>0){
                    timePoint += 1.0
                    //time point line
                    let x = Double(j) * self.sampleWidth;
                    
                    let  bezierPath =  UIBezierPath(rect:  CGRect(x: CGFloat(x), y: 24, width: 1, height: 6))
                    self.timePointColor.setFill()
                    bezierPath.fill()
                    
                    
                    //time point number
                    let widthMax = ((1.0 / self.intervalTime) * self.sampleWidth)
                    let textAtX = Double(j) * self.sampleWidth - (widthMax / 2.0)
                    
                    
                    let context: CGContext = UIGraphicsGetCurrentContext()!
                    let textContent: String = self.formatRecordTime(time: time + timeSpace)//String(format: "%.0f", time + sss)
                    let textRect = CGRect(x:CGFloat(textAtX), y:5, width:CGFloat(widthMax), height:20)
                    let textStyle = NSMutableParagraphStyle()
                    
                    textStyle.alignment = NSTextAlignment.center
                    
                    let textFontAttributes: [String : AnyObject] = [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0), NSForegroundColorAttributeName: self.timePointColor, NSParagraphStyleAttributeName: textStyle]
                    context.saveGState()
                    context.clip(to: textRect)
                    textContent.draw(in: textRect, withAttributes: textFontAttributes)
                    context.restoreGState()
                    
                }
            }
            
        }
        
        self.waveColor.setFill()
        let  centerLine =  UIBezierPath(rect:  CGRect(x:0, y:(self.bounds.size.height + timePointViewHiehgt)/2.0 - 0.25, width:self.bounds.size.width, height:0.5))
        centerLine.fill()
        let  topLine =  UIBezierPath(rect:  CGRect(x:0, y:30, width:self.bounds.size.width, height:0.5))
        topLine.fill()
        let  bottomLine =  UIBezierPath(rect:  CGRect(x:0, y:self.bounds.size.height-0.5, width:self.bounds.size.width, height:0.5))
        bottomLine.fill()
        
        UIColor.red.setFill()
        let  divisionLine =  UIBezierPath(rect:  CGRect(x:CGFloat(Double(divisorSampleNum)*sampleWidth), y:timePointViewHiehgt+12, width:1, height:self.bounds.size.height-timePointViewHiehgt-24))
        divisionLine.fill()
        UIColor.red.setStroke()
        let arc1 = UIBezierPath(arcCenter: CGPoint(x: CGFloat(Double(divisorSampleNum)*sampleWidth)+0.5, y: timePointViewHiehgt+9), radius: 4, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        arc1.lineWidth = 2
        arc1.stroke()
        let arc2 = UIBezierPath(arcCenter: CGPoint(x: CGFloat(Double(divisorSampleNum)*sampleWidth)+0.5, y: self.bounds.size.height-9), radius: 4, startAngle: 0, endAngle: CGFloat(Double.pi*2), clockwise: true)
        arc2.lineWidth = 2
        arc2.stroke()
    }
    
    // MARK: - Public methods
    public func setWaverLevelCallback(_ callback:@escaping (_ wave:AudioWave)->()){
        self.callback = callback
        self.displayLink?.invalidate()
        self.displayLink = CADisplayLink(target: self, selector: #selector(invokeWaveCallback))
        self.waveDataSource.removeAll()
        self.scheduledCount = 0
        for _ in 0...self.divisorSampleNum {
            self.waveDataSource.append(0)
            self.scheduledCount = self.scheduledCount + 1;
        }
        self.beginTimePoint = 0 - divisorSampleNum-1
        self.displayLink?.add(to: RunLoop.current, forMode: .commonModes)
//        if self.timer != nil {
//            self.timer!.cancel()
//            self.timer = nil
//        }
//
//        self.timer = DispatchSource.makeTimerSource(queue: .main)
//        self.timer?.scheduleRepeating(wallDeadline: DispatchWallTime.now(), interval: self.intervalTime)
//        self.timer?.setEventHandler {
//            self.updateValue()
//        }
//        // 启动定时器
//        self.timer?.resume()
        
    }
    
    func invokeWaveCallback() {
        self.callback?(self)
    }
    
    public func setLevel(_ level:Double){
        let l = fabsl((pow (10, (level+160.0) / powerFactor) - min) / (max - min));
        
        let count = self.waveDataSource.count
        if count > self.divisorSampleNum{
            self.waveDataSource.remove(at: 0)
        }
        
        self.waveDataSource.append(self.scheduledCount%3==0 ? l*100:0)
        
        self.scheduledCount = self.scheduledCount + 1;
        
        self.setNeedsDisplay()
    }
    
//    public func stop(){
//        if self.timer != nil {
//            self.timer?.cancel()
//            self.timer = nil
//        }
//    }
    
    
    
    // MARK: - Private methods
    private func commonInit(){
        self.backgroundColor = UIColor.clear
        self.sampleNum = Int(ceil(Double(self.bounds.size.width) / self.sampleWidth))
        self.secondsInWidth = Int(floor(Double(self.bounds.size.width) / (self.sampleWidth / self.intervalTime)))
        self.divisorSampleNum = Int(Double(self.sampleNum)*widthDivisor);
        self.min = pow (10, 0 / powerFactor);
        self.max = pow (10, 160 / powerFactor);
    }
    
//    private func updateValue(){
//        if self.dataSource != nil {
//            self.waveDataSource = self.dataSource!.audioWave(audioWave: self)
//        }
//        self.scheduledCount += 1
//        self.setNeedsDisplay()
//    }
    
    
    private func formatRecordTime(time: TimeInterval) -> String {
        let hours = (Int(time) / 3600) % 60;
        let minutes = (Int(time) / 60) % 60;
        let seconds = Int(time) % 60;
        if(hours == 0){
            return String(format: "%02d:%02d",minutes,seconds)
        }
        return String(format: "%02d:%02d:%02d",hours,minutes,seconds)
    }
    
}


public protocol AudioWaveDataSource : NSObjectProtocol {
    func audioWave(audioWave: AudioWave) -> [Double];
    
}

