//
//  ARDViewController.h
//  AugumentedRealityDemo
//
//  Created by Apple on 10/01/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "baseapi.h"

@interface ARDViewController : UIViewController  <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    UIImagePickerController *imagePickerController;
    TessBaseAPI *tesseract;
    UIImageView *imageView;
    UILabel *label;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *label;

- (IBAction)choosePhoto:(id)sender;
- (IBAction)takePhoto:(id)sender;

- (void) startTesseract;
- (NSString *) applicationDocumentsDirectory;
- (NSString *) ocrImage:(UIImage *)uiimage;
- (UIImage *) resizeImage:(UIImage *)image;

@end