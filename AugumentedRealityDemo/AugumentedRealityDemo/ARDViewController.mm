//
//  ARDViewController.m
//  AugumentedRealityDemo
//
//  Created by Apple on 10/01/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "ARDViewController.h"
#import <math.h>

static inline double radians (double degrees) {return degrees * M_PI/180;}

@interface ARDViewController ()

@end

@implementation ARDViewController

@synthesize imageView, label;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UserActions
- (IBAction)takePhoto:(id)sender
{
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
    {
        imagePickerController = [[UIImagePickerController alloc]init];
        imagePickerController.delegate = self;
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!" message:@"Your device doesn't have the camera" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)choosePhoto:(id)sender
{
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark ApplicationDocumentDirectory
- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectryPath = [paths objectAtIndex:0];
    return documentsDirectryPath;
}

#pragma mark UIImagePickerController
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *croppedImage = [self resizeImage:image];
    imageView.image = croppedImage;
    NSString *text = [self ocrImage:croppedImage];
    label.text = text;
}

#pragma mark Image Processing/Resizing
- (void)startTesseract
{
    NSString *dataPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"tessdata"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:dataPath])
    {
        NSString *bundlePath = [[NSBundle mainBundle]bundlePath];
        NSString *tessDataPath = [bundlePath stringByAppendingPathComponent:@"tessdata"];
        if (tessDataPath)
        {
            [fileManager copyItemAtPath:tessDataPath toPath:dataPath error:NULL];
        }
    }
    NSString *dataWithSlash = [[self applicationDocumentsDirectory]stringByAppendingString:@"/"];
    setenv("TESSDATA_PREFIX", [dataWithSlash UTF8String], 1);
    
    tesseract = new TessBaseAPI();
    tesseract -> SimpleInit([dataPath cStringUsingEncoding:NSUTF8StringEncoding], "eng", false);
}

- (NSString *)ocrImage:(UIImage *)uiimage
{
    CGSize imageSize = [uiimage size];
    double bytes_per_line = CGImageGetBytesPerRow([uiimage CGImage]);
    double bytes_per_pixel = CGImageGetBitsPerPixel([uiimage CGImage]) / 8.0;
   
    CFDataRef data = CGDataProviderCopyData(CGImageGetDataProvider([uiimage CGImage]));
    const UInt8 *imageData = CFDataGetBytePtr(data);
    
    //processing of image for a while
    
    char *text = tesseract->TesseractRect(imageData, (int)bytes_per_pixel, (int)bytes_per_line, 0, 0, (int)imageSize.height, (int)imageSize.width);
    NSLog(@"Processed Text :: %@",[NSString stringWithCString:text encoding:NSUTF8StringEncoding]);
    return [NSString stringWithCString:text encoding:NSUTF8StringEncoding];
}

- (UIImage *)resizeImage:(UIImage *)image
{
    CGImageRef imageref = [image CGImage];
    CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageref);
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    
    if (alphaInfo == kCGImageAlphaNone)
    {
        alphaInfo = kCGImageAlphaNoneSkipLast;
    }
    int width, height;
    width = [image size].width;
    height = [image size].height;
    CGContextRef bitmap;
    
    if (image.imageOrientation == UIImageOrientationUp | image.imageOrientation == UIImageOrientationDown)
    {
        bitmap = CGBitmapContextCreate(NULL, width, height, CGImageGetBitsPerComponent(imageref), CGImageGetBytesPerRow(imageref), colorSpaceInfo, alphaInfo);
    }
    else
    {
        bitmap = CGBitmapContextCreate(NULL, height, width, CGImageGetBitsPerComponent(imageref), CGImageGetBytesPerRow(imageref), colorSpaceInfo, alphaInfo);
    }
    if (image.imageOrientation == UIImageOrientationLeft)
    {
        NSLog(@"image is in Left Orientation");
        CGContextRotateCTM(bitmap, radians(90));
        CGContextTranslateCTM(bitmap, 0, -height);
    }
    else if (image.imageOrientation == UIImageOrientationRight)
    {
        NSLog(@"image is in Right Orientation");
        CGContextRotateCTM(bitmap, radians(-90));
        CGContextTranslateCTM(bitmap, -width, 0);
    }
    else if (image.imageOrientation == UIImageOrientationUp)
    {
        NSLog(@"image is in Up Prientation");
    }
    else if (image.imageOrientation == UIImageOrientationDown)
    {
        NSLog(@"image is in Down Orientation");
        CGContextRotateCTM(bitmap, radians(-180));
        CGContextTranslateCTM(bitmap, width, height);
    }
    CGContextDrawImage(bitmap, CGRectMake(0, 0, width, height), imageref);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage *result = [UIImage imageWithCGImage:ref];
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    return result;
}

@end






















