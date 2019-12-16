//
//  Model.swift
//  Quikr Demo
//
//  Created by Akshay Somkuwar on 07/12/19.
//  Copyright © 2019 Akshay Somkuwar. All rights reserved.
//

//class VideoMerger private constructor(private val context: Context) {
//
//    private var videos: List<File>? = null
//    private var callback: FFMpegCallback? = null
//    private var outputPath = ""
//    private var outputFileName = ""
//
//    func setVideoFiles(originalFiles: List<File>): VideoMerger {
//        this.videos = originalFiles
//        return this
//    }
//
//    func setCallback(callback: FFMpegCallback): VideoMerger {
//        this.callback = callback
//        return this
//    }
//
//    func setOutputPath(output: String): VideoMerger {
//        this.outputPath = output
//        return this
//    }
//
//    func setOutputFileName(output: String): VideoMerger {
//        this.outputFileName = output
//        return this
//    }
//
//    /*
//     * For concat'ing videos there are a few properties that have to be equal. So before executing the concat, you better "normalize" or "format" all you inputs to share these properties:
//     * Video resolution
//     * Video framerate (actually frame rate dont need to match, but the timescale)
//     * Video interlacing
//     * Video colorspace (e.g. YUV 4:2:0)
//     * Video codec
//     * Audio samplerate
//     * Audio channels and track / layout
//     * Audio codec(s)
//     */
//    func merge() {
//
//        if (videos == null || videos!!.isEmpty()) {
//            callback!!.onFailure(IOException("File not exists"))
//            return
//        }
//
//        for (v in videos!!) {
//            if (!v.canRead()) {
//                callback!!.onFailure(IOException("Can't read the file. Missing permission?"))
//                return
//            }
//        }
//
//        val outputLocation = Utils.getConvertedFile(outputPath, outputFileName)
//
//        val inputCommand = arrayListOf<String>()
//
//        //Add all paths
//        for (i in videos!!) {
//            inputCommand.add("-i")
//            inputCommand.add(i.path)
//        }
//        //Apply filter graph
//        inputCommand.add("-filter_complex")
//
//        //Compose concatenation commands
//        val stringBuilder = StringBuilder()
//
//        //'setpts' and 'asetpts' will prevent a jerky output due to presentation timestamp issues
//        //Set SAR,DAR & Scale to merge/concatenate videos of different sizes
//        //'setsar' filter sets the Sample (aka Pixel) Aspect Ratio for the filter output video
//        for (i in 0 until videos!!.size) {
//            stringBuilder.append("[$i:v]setpts=PTS-STARTPTS,setsar=1,setdar=1/1,scale=320x320[v$i]; [$i:a]asetpts=PTS-STARTPTS[a$i];")
//        }
//
//        for (i in 0 until videos!!.size) {
//            stringBuilder.append("[v$i][a$i]")
//        }
//
//        //Concat command
//        stringBuilder.append("concat=n=${videos!!.size}:v=1:a=1[v][a]")
//
//        //Complete Command
//        val cmd = arrayOf<String>(
//                "-map",
//                "[v]",
//                "-map",
//                "[a]",
//                "-preset", //Presets can be ultrafast, superfast, veryfast, faster, fast, medium (default), slow and veryslow.
//                "medium", //Using a slower preset gives you better compression, or quality per file size.
//                "-crf", //Constant Rate Factor
//                "18", //Value from 0 to 51, 23 is default, Large Value for highest quality
//                outputLocation.path,
//                "-y" //Overwrite output files without asking
//        )
//
//        val finalCommand = (inputCommand + stringBuilder.toString() + cmd).toTypedArray()
//
//        try {
//            FFmpeg.getInstance(context).execute(finalCommand, object : ExecuteBinaryResponseHandler() {
//                override func onStart() {}
//
//                override func onProgress(message: String?) {
//                    callback!!.onProgress(message!!)
//                }
//
//                override func onSuccess(message: String?) {
//                    Utils.refreshGallery(outputLocation.path, context)
//                    callback!!.onSuccess(outputLocation, OutputType.TYPE_VIDEO)
//
//                }
//
//                override func onFailure(message: String?) {
//                    if (outputLocation.exists()) {
//                        outputLocation.delete()
//                    }
//                    callback!!.onFailure(IOException(message))
//                }
//
//                override func onFinish() {
//                    callback!!.onFinish()
//                }
//            })
//        } catch (e: Exception) {
//            callback!!.onFailure(e)
//        } catch (e2: FFmpegCommandAlreadyRunningException) {
//            callback!!.onNotAvailable(e2)
//        }
//
//    }
//
//    func companion object {
//
//        val TAG = "VideoMerger"
//
//        func with(context: Context): VideoMerger {
//            return VideoMerger(context)
//        }
//    }
//}

import Foundation
import UIKit

struct AdModel: Codable {
    var title: String = String()
    var description: String = String()
    var image: String = String()
    var price: String = String()
    init() {
        self.title = ""
        self.description = ""
        self.image = ""
        self.price = ""
    }
    init(json: [String: Any]) {
        self.title = json["title"] as? String ?? ""
        self.description = json["description"] as? String ?? ""
        self.image = json["image"] as? String ?? ""
        self.price = json["price"] as? String ?? ""
    }
}

extension String {

    static func random(length: Int = 20) -> String {

        let charSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var c = charSet.map { String($0) }
        var s:String = ""
        for _ in (1...length) {
            s.append(c[Int(arc4random()) % c.count])
        }
        return s
    }
}


struct Device {
    // iDevice detection code
    static let IS_IPAD             = UIDevice.current.userInterfaceIdiom == .pad
    static let IS_IPHONE           = UIDevice.current.userInterfaceIdiom == .phone
    static let IS_RETINA           = UIScreen.main.scale >= 2.0
    
    static let SCREEN_WIDTH        = Int(UIScreen.main.bounds.size.width)
    static let SCREEN_HEIGHT       = Int(UIScreen.main.bounds.size.height)
    static let SCREEN_MAX_LENGTH   = Int( max(SCREEN_WIDTH, SCREEN_HEIGHT) )
    static let SCREEN_MIN_LENGTH   = Int( min(SCREEN_WIDTH, SCREEN_HEIGHT) )
    
    static let IS_IPHONE_4_OR_LESS = IS_IPHONE && SCREEN_MAX_LENGTH  < 568
    static let IS_IPHONE_5         = IS_IPHONE && SCREEN_MAX_LENGTH == 568
    static let IS_IPHONE_6         = IS_IPHONE && SCREEN_MAX_LENGTH == 667
    static let IS_IPHONE_6P        = IS_IPHONE && SCREEN_MAX_LENGTH == 736
    static let IS_IPHONE_X         = IS_IPHONE && SCREEN_MAX_LENGTH == 812
    
    static func navigationBarHeight() -> CGFloat {
        var size: CGFloat = 0
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                print("iPhone 5 or 5S or 5C")
                size = 70
            case 1334:
                print("iPhone 6/6S/7/8")
                size = 70
            case 1920, 2208:
                print("iPhone 6+/6S+/7+/8+")
                size = 70
            case 2436:
                print("iPhone X, Xs")
                size = 90
            case 2688:
                print("iPhone Xs Max")
                size = 90
            case 1792:
                print("iPhone Xr")
                size = 90
            default:
                print("unknown")
                size = 70
            }
        } else {
            size = 70
        }
        return size
    }
    
    static var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    
}
