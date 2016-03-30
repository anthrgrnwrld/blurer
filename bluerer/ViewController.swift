//
//  ViewController.swift
//  bluerer
//
//  Created by Masaki Horimoto on 2016/03/22.
//  Copyright © 2016年 Masaki Horimoto. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Cameraボタンを押した時
     */
    @IBAction func pressCameraButton(sender: AnyObject) {
        
        print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        
    }

    /**
     Photo Libraryボタンを押した時
     */
    @IBAction func pressLibraryButton(sender: AnyObject) {
        
        //print("\(NSStringFromClass(self.classForCoder)).\(__FUNCTION__) is called!")
        
        shiftToImagePickerController()  //ImagePickerControllerに遷移する
        
    }
    
    /**
     ImagePickerControllerに遷移する
     */
    func shiftToImagePickerController() {
        //print("\(NSStringFromClass(self.classForCoder)).\(__FUNCTION__) is called!")
        
        //Libraryにアクセス出来るか確認. 出来なければreturn.
        guard UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) else {
            print("Cannot access PhotoLibrary.")
            return
        }
        
        let imagePickerController = UIImagePickerController()   //ImagePickerCOntrollerをインスタンス化
        imagePickerController.delegate = self                   //delegateを自身に設定
        imagePickerController.sourceType = .PhotoLibrary        //カメラとライブラリのどちらを表示するか. 今回はライブラリを表示
        
        //imagePickerControllerに遷移
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo: [String : AnyObject]) {
        print("\(NSStringFromClass(self.classForCoder)).\(#function) is called!")
        
        //ImagePickerControllerで選択した写真にアクセス出来るか確認. 出来なければFatalError.
        guard let image = didFinishPickingMediaWithInfo[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("originalImage is invalid.")
        }
        
        //editViewControllerをインスタンス化出来きるか確認. 出来なければFatalError.
        guard let editViewController = storyboard?.instantiateViewControllerWithIdentifier("EditViewController") as? EditViewController else {
            fatalError("EditViewController is invalid.")
        }

        editViewController.image = image                                //選択した写真の遷移後のviewControllerでの表示準備
        picker.pushViewController(editViewController, animated: true)   //EditViewControllerへ遷移
        
    }
    
    
    
}

