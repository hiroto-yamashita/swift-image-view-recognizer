//
//  ViewController.swift
//  imageRecogSwift
//
//  Created by 山下　寛人 on 2014/10/03.
//  Copyright (c) 2014年 山下　寛人. All rights reserved.
//

import UIKit

class ViewController: UIViewController, GPImageRecognitionEngineDelegate, UIAlertViewDelegate {

    var recognitionEngine: GPImageRecognitionEngine?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var path = NSBundle.mainBundle().pathForResource("テストデータ", ofType: "desc")
        var serializedDataSet: NSData
        var fileHandle: NSFileHandle? = NSFileHandle(forReadingAtPath: path!)
        if fileHandle == nil {
            serializedDataSet = fileHandle!.readDataToEndOfFile()
        } else {
            var fileManager = NSFileManager()
            if (!fileManager.fileExistsAtPath(path!)) {
                fileManager.createFileAtPath(path!, contents: NSData(), attributes: nil)
            }
            var images = NSMutableArray()
            images.addObject(UIImage(named: "scene.jpg"))
            images.addObject(UIImage(named: "lenna.png"))
            images.addObject(UIImage(named: "apple.jpg"))
            images.addObject(UIImage(named: "paris.jpg"))
            
            var tags = NSMutableArray()
            tags.addObject(NSString(string: "scene").dataUsingEncoding(NSUTF8StringEncoding)!)
            tags.addObject(NSString(string: "lenna").dataUsingEncoding(NSUTF8StringEncoding)!)
            tags.addObject(NSString(string: "apple").dataUsingEncoding(NSUTF8StringEncoding)!)
            tags.addObject(NSString(string: "paris").dataUsingEncoding(NSUTF8StringEncoding)!)
            var dataset = GPDescriptorDataset(UIImages: images, tags: tags, maxDetectionNum: 400)
            dataset.tag = NSString(string: "dataset").dataUsingEncoding(NSUTF8StringEncoding)
            
            serializedDataSet = dataset.serialize()
            var fileHandle: NSFileHandle? = NSFileHandle(forWritingAtPath: path!)
            if (fileHandle != nil) {
                fileHandle!.writeData(serializedDataSet)
            }
        }
        
        var dataset = GPDescriptorDataset(serializedDataset: serializedDataSet)
        self.recognitionEngine = GPImageRecognitionEngine.sharedManager()
        self.recognitionEngine!.dataset = dataset
        self.recognitionEngine!.previewView = self.view
        self.recognitionEngine!.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.recognitionEngine?.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didImageRecognition(result: GPImageRecognitionResult!) {
        print("didImageRecognition:")
        if (result.isRecognized == 1) {
            self.recognitionEngine?.stop()
            dispatch_async(dispatch_get_main_queue(), {
                var tag = NSString(data: result.datasetTag, encoding: NSUTF8StringEncoding)
                var desc = NSString(data: result.descriptorTag, encoding: NSUTF8StringEncoding)
                var str = "\(tag):\(desc)"
                UIAlertView(title: "Result.", message: str, delegate: self, cancelButtonTitle: nil, otherButtonTitles: "Yes").show()
            })
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        self.recognitionEngine?.start()
    }

}

