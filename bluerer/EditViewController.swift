//
//  EditViewController.swift
//  bluerer
//
//  Created by Masaki Horimoto on 2016/03/22.
//  Copyright © 2016年 Masaki Horimoto. All rights reserved.
//

import UIKit
import AVFoundation

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate  {

    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var blurView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var bottomView: UIView!
    
    var image : UIImage?        //ライブラリから取得した写真が入る
    var resizedImage : UIImage?
    var is1st: Bool = false     //viewDidLoadを通った直後か否かを判断
    
    var lastPoint: CGPoint!
    
    var red: CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    var blendMode: CGBlendMode = .Clear
    var color: UIColor?
    var bezierPath: UIBezierPath?
    var bezierPathShadow: UIBezierPath?
    var firstMovedFlg: Bool = true
    
    var countTest = 0
    let maxBlurValue: Float = 20.0
    var drawSize: CGFloat! = 50.0
    var sliderBlurValue: Float = 0.25
    var sliderDrawSizeValue: Float = 0.5
    
    
    var selectedButton: selectedSliderButton?
    
    enum selectedSliderButton {
        
        case drawSize
        case blurLevel

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0    // 最小拡大率
        scrollView.maximumZoomScale = 4.0    // 最大拡大率
        scrollView.zoomScale = 1.0           // 表示時の拡大率
        
        //imageに値が入っているか確認. 入っていなければreturnする.
        guard let image = image else {
            print("Cannot access PhotoLibrary.")
            return
        }

        //navigationControllerにアクセス出来るか確認. 出来なければFatalError.
        guard let navigationController = self.navigationController else {
            fatalError("navigationController is invalid.")
        }
        
        let navigationBarHeight = navigationController.navigationBar.frame.height - 5
        let marginHeight = navigationBarHeight * image.size.width / self.view.bounds.size.width * 2
        
        let size = CGSizeMake(image.size.width , image.size.height + marginHeight)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, image.size.width , image.size.height))
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let resizedImage = self.resizedImage else {
            print("Cannot access PhotoLibrary.")
            return
        }

        pictureView.contentMode = .ScaleAspectFit   //contentModeの設定
        pictureView.image = resizedImage            //pictureViewにimageを適応
 
        let blurImage = createblurImage(resizedImage, value: maxBlurValue * slider.value)      //ぼかしViewの作成
        blurView.contentMode = .ScaleAspectFit      //contentModeの設定
        
        blurView.image = blurImage                  //pictureViewにblurImageを適応
        
        //bar周りの表示設定. ここでは非表示に.
        navigationController.navigationBarHidden = true
        navigationController.toolbarHidden = true
        
        //ここでtrueにする (viewDidAppearでfalseに戻す)
        is1st = true
        
        let myPan = UIPanGestureRecognizer(target: self, action: #selector(EditViewController.panGesture(_:)))
        myPan.maximumNumberOfTouches = 1
        self.scrollView.addGestureRecognizer(myPan)
        
        //scrollView.scrollEnabled = false
        
        self.automaticallyAdjustsScrollViewInsets = false   //draw時にnavigationBarを表示した時に写真が少し上にずれる問題の対策.
        
        selectedButton = selectedSliderButton.drawSize

        
//        // BarButtonItemを作成する.
//        let myRightBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: #selector(EditViewController.printtest))
//        
//        // Barの左側に配置する.
//        self.navigationItem.setLeftBarButtonItem(myRightBarButton, animated: true)
        
        
        navigationController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationController.navigationBar.shadowImage = UIImage()

        UINavigationBar.appearance().tintColor = UIColor.orangeColor()

        
 
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "hoge", style: .Plain, target: self, action: #selector(EditViewController.printtest))
//        let item = UIBarButtonItem()
//        item.title = "hoge"
//        self.navigationItem.backBarButtonItem?.title = "item"

        
        //print("\(self.navigationItem.backBarButtonItem?.title)")
        //print("\(self.navigationItem.leftBarButtonItem?.title)")
//        print("\(self.navigationItem.leftBarButtonItems?[0].title)")
//        print("\(self.navigationItem.leftBarButtonItems?[1].title)")
//        print("\(self.navigationItem.leftBarButtonItems?[2].title)")
//        print("\(self.navigationItem.leftBarButtonItems?[3].title)")
        
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "hoge", style: .Plain, target: nil, action: nil)
//        let item = UIBarButtonItem()
//        item.title = "hoge"
//        self.navigationItem.leftBarButtonItem = item
        //UINavigationBar.appearance().tintColor = UIColor.redColor()
        //self.navigationItem.rightBarButtonItem = item



        
//        let navigationBarHeight = navigationController.navigationBar.frame.height
//        let imageRect = AVMakeRectWithAspectRatioInsideRect(self.pictureView.image!.size, self.pictureView.bounds)
        
        //self.scrollView.bounds.origin.y += (imageRect.origin.y - navigationBarHeight)
        
//        self.scrollView.translatesAutoresizingMaskIntoConstraints = false
        

        

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        //navigationControllerにアクセス出来るか確認. 出来なければFatalError.
        guard let navigationController = self.navigationController else {
            fatalError("navigationController is invalid.")
        }
 
        navigationController.setNavigationBarHidden(true, animated: true)
        bottomView.hidden = true
        
        // 透明にしたナビゲーションを元に戻す処理
        navigationController.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        navigationController.navigationBar.shadowImage = nil
    }
    
    override func viewDidLayoutSubviews() {
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        //navigationBarを表示した時に写真が少し下にずれる問題の対策.
        
        self.scrollView.contentInset = UIEdgeInsetsZero
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        if !is1st { return }
        
        //navigationControllerにアクセス出来るか確認. 出来なければFatalError.
        guard let navigationController = self.navigationController else {
            fatalError("navigationController is invalid.")
        }
        
        //アニメーションしてbarを表示する
        let isDisplayBar = navigationController.navigationBarHidden
        navigationController.setNavigationBarHidden(!isDisplayBar, animated: true)
        //navigationController.setToolbarHidden(!isDisplayBar, animated: true)
        
        bottomView.hidden = !bottomView.hidden
        
        //ここでfalseにする (役割おしまい)
        is1st = false
    
    }
    


    /**
     引数のimageを基にぼかしimageを作成する
     
     - parameter imageView : ぼかし画像の元画像
     - returns : ぼかし適応後画像を返す
     */
    private func createblurImage(image: UIImage, value: Float) -> UIImage?
    {
        let context = CIContext(options: nil)
        var size: CGSize!
        let maxWidth: CGFloat = scrollView.bounds.size.width
        //let maxWidth: CGFloat = 1080

        

        if image.size.width > maxWidth {
            
            let ratio = image.size.height / image.size.width
            size = CGSizeMake(maxWidth , maxWidth * ratio)
            
        } else {
            
            size = image.size
            
        }
        
        //size = image.size
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))

        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let inputImage = CIImage(CGImage: resizedImage.CGImage!)
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue((value), forKey: kCIInputRadiusKey)
        let outputImage = filter?.outputImage
        
        var cgImage:CGImageRef?
        
        guard let asd = outputImage else {
            return nil
        }
        
        let rect = CGRect(origin: CGPointZero, size: resizedImage.size)
        
        cgImage = context.createCGImage(asd, fromRect: rect)
        
        guard let cgImageA = cgImage else {
            return nil
        }

        var retImage: UIImage!
        
        if value != 0 {
            retImage = UIImage(CGImage: cgImageA)
        } else {
            retImage = image
        }
        
        return retImage
        
    }
    
    internal func panGesture(sender: AnyObject) {
    
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        
        guard let pan = sender as? UIPanGestureRecognizer else { return }
        
        let touchPoint = pan.locationInView(pictureView)
        
        guard let image_ = self.pictureView.image else {
            return
        }
        
        guard let drawSize = drawSize else {
            return
        }
        
        var contextSize: CGSize!
        let maxWidth: CGFloat = 1080
        let lineWidth: CGFloat = drawSize
        var convertLineWidth: CGFloat!
        
        if image_.size.width > maxWidth {
            
            let ratio = image_.size.height / image_.size.width
            contextSize = CGSizeMake(maxWidth , maxWidth * ratio)
            convertLineWidth = lineWidth * maxWidth / scrollView.bounds.size.width
            
        } else {
            
            contextSize = image_.size
            convertLineWidth = lineWidth * contextSize.width / scrollView.bounds.size.width
            
        }
        
        //navigationControllerにアクセス出来るか確認. 出来なければFatalError.
        guard let navigationController = self.navigationController else {
            fatalError("navigationController is invalid.")
        }

        
        switch pan.state {
        case .Began:
            print("Start dragging")
            lastPoint = touchPoint
            let convertLastPoint = convertPointForContext(originalPoint: lastPoint, contextSize: contextSize)
            
            bezierPath = UIBezierPath()
            bezierPath!.lineCapStyle = .Round
            bezierPath!.lineWidth = convertLineWidth
            bezierPath!.moveToPoint(convertLastPoint)
            firstMovedFlg = false
            
            navigationController.setNavigationBarHidden(true, animated: true)
            bottomView.hidden = true
            
        case .Changed:

            let newPoint = touchPoint

            guard let bezierPath_ = bezierPath else {
                
                print("guard")
                return
            }
            
            if !firstMovedFlg {
                firstMovedFlg = true
                lastPoint = newPoint;
                return
            }
            
            
            
            let middlePoint = CGPointMake((lastPoint.x + newPoint.x) / 2, (lastPoint.y + newPoint.y) / 2)
            
            let convertMiddlePoint = convertPointForContext(originalPoint: middlePoint, contextSize: contextSize)
            let convertLastPoint   = convertPointForContext(originalPoint: lastPoint, contextSize: contextSize)
            
            bezierPath_.addQuadCurveToPoint(convertMiddlePoint, controlPoint: convertLastPoint)
            
            UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
            
            self.pictureView.image?.drawInRect(CGRectMake(0, 0, contextSize.width, contextSize.height))
            
            color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
            bezierPath_.strokeWithBlendMode(blendMode, alpha: alpha) //透明色
            
            color!.setStroke()
            
            bezierPath_.stroke()
            
            self.pictureView.image = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            lastPoint = newPoint
            
            
        case .Ended:
            print("Finish dragging")
            
            navigationController.setNavigationBarHidden(false, animated: true)
            bottomView.hidden = false
            
//            UIGraphicsBeginImageContextWithOptions(contextSize, false, 0.0)
//            self.blurView.image?.drawInRect(CGRectMake(0, 0, contextSize.width, contextSize.height))
//            self.pictureView.image?.drawInRect(CGRectMake(0, 0, contextSize.width, contextSize.height))
//            self.pictureView.image = UIGraphicsGetImageFromCurrentImageContext()
//            
//            UIGraphicsEndImageContext()
            
            
        default:
            ()
        }
        
    }
    
    func convertPointForContext(originalPoint originalPoint: CGPoint, contextSize: CGSize) -> CGPoint {
        
        let viewSize = scrollView.frame.size
        var ajustContextSize = contextSize
        var diffSize: CGSize = CGSizeMake(0, 0)
        let viewRatio = viewSize.width / viewSize.height
        let contextRatio = contextSize.width / contextSize.height
        let isWidthLong = viewRatio < contextRatio ? true : false
        
        if isWidthLong {
            
            ajustContextSize.height = ajustContextSize.width * viewSize.height / viewSize.width
            diffSize.height = (ajustContextSize.height - contextSize.height) / 2
            
        } else {
            
            ajustContextSize.width = ajustContextSize.height * viewSize.width / viewSize.height
            diffSize.width = (ajustContextSize.width - contextSize.width) / 2
            
        }
        
        let contextPoint = CGPointMake(originalPoint.x * ajustContextSize.width / viewSize.width - diffSize.width,
                                       originalPoint.y * ajustContextSize.height / viewSize.height - diffSize.height)
        
        
        return contextPoint
        //return originalPoint
    }
    
    @IBAction func slideValue(sender: AnyObject) {
        
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        
        //print("\(blurValue.value)")
        
        //resizedImageに値が入っているか確認. 入っていなければreturnする.
        guard let resizedImage = self.resizedImage else {
            print("Cannot access PhotoLibrary.")
            return
        }
        
        guard let selectedButton = selectedButton else {
            fatalError("selectedButton is invalid.")
        }
        
        switch selectedButton {
        case selectedSliderButton.drawSize:
            print("a")
            
            drawSize = 100.0 * CGFloat(slider.value)
            
        case selectedSliderButton.blurLevel:
            
            let blurImage = createblurImage(resizedImage, value: maxBlurValue * slider.value)      //ぼかしViewの作成
            blurView.contentMode = .ScaleAspectFit      //contentModeの設定
            blurView.image = blurImage                  //pictureViewにblurImageを適応
            
        }
        
    }
    
    
    /**
     写真の拡大縮小に対応
     */
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        
        //navigationControllerにアクセス出来るか確認. 出来なければFatalError.
        guard let navigationController = self.navigationController else {
            fatalError("navigationController is invalid.")
        }
        
        if navigationController.navigationBarHidden != true {
            navigationController.setNavigationBarHidden(true, animated: true)
        }
        
        if bottomView.hidden != true {
            bottomView.hidden = true
        }
        
        return self.displayView
    }
    
    func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
        
        //print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
 
        //navigationControllerにアクセス出来るか確認. 出来なければFatalError.
        guard let navigationController = self.navigationController else {
            fatalError("navigationController is invalid.")
        }
        
        navigationController.setNavigationBarHidden(false, animated: true)
        bottomView.hidden = false
        
    }
    
    @IBAction func pressDrawSizeButton(sender: AnyObject) {
        
        selectedButton = selectedSliderButton.drawSize
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.slider.setValue(self.sliderDrawSizeValue, animated: true)
            }, completion: nil)

        
    }
    
    @IBAction func pressBlurLevelButton(sender: AnyObject) {
        
        selectedButton = selectedSliderButton.blurLevel
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.slider.setValue(self.sliderBlurValue, animated: true)
            }, completion: nil)
        
    }
    
    func printtest() {
        print("aaaaaaaaaaaa")
    }

}
