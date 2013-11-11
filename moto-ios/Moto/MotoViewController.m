//
//  MotoViewController.m
//  Moto
//
//  Created by Vikram Rangnekar on 10/12/13.
//  Copyright (c) 2013 Vikram Rangnekar. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/CGImageProperties.h>

#import "UIImage+Extra.h"
#import "UIImage+Resize.h"

#import "MotoViewController.h"
#import "WXApiObject.h"
#import "WXApi.h"

@interface MotoViewController ()


@end

@implementation MotoViewController

UIImage *finalImage, *backImage, *frontImage;

AVCaptureStillImageOutput *backCameraStillImageOutput;
AVCaptureStillImageOutput *frontCameraStillImageOutput;

AVCaptureSession *backCameraSession;
AVCaptureSession *frontCameraSession;

AVCaptureDevice *frontCamera;
AVCaptureDevice *backCamera;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        
        UIView *cameraViewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight / 2)];
        UIView *cameraViewBottom = [[UIView alloc]
                                    initWithFrame:CGRectMake(0, (screenHeight / 2), screenWidth, screenHeight / 2)];

        [self.view addSubview:cameraViewTop];
        [self.view addSubview:cameraViewBottom];
        
        backCameraStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        frontCameraStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        
        [self detectCameras];
        
        backCameraSession = [self setupVideoSession:cameraViewTop
                                             device:backCamera
                                   stillImageOutput:backCameraStillImageOutput];
        
        frontCameraSession = [self setupVideoSession:cameraViewBottom
                                              device:frontCamera
                                    stillImageOutput:frontCameraStillImageOutput];
        
        cancelButton.hidden = true;
        addButton.hidden = true;

        
        [self.view bringSubviewToFront:mainButton];
        [self.view bringSubviewToFront:cancelButton];
        [self.view bringSubviewToFront:addButton];

        [backCameraSession startRunning];

    }
    return self;
}

- (void) detectCameras {
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices) {
        
        NSLog(@"Device name: %@", [device localizedName]);
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                NSLog(@"Device position : back");
                backCamera = device;
            }
            else {
                NSLog(@"Device position : front");
                frontCamera = device;
            }
        }
    }
}

- (AVCaptureSession *) setupVideoSession:(UIView *) cameraView
                                  device:(AVCaptureDevice *) cameraDevice
                       stillImageOutput:(AVCaptureStillImageOutput *) stillImageOutput

{
    NSError *error = nil;
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if ([session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
        [session setSessionPreset:AVCaptureSessionPresetPhoto];
    }
    else {
        [session setSessionPreset:AVCaptureSessionPresetMedium];
    }
    
    // Select a video device, make an input
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:cameraDevice error:&error];
    //require(error == nil, bail);
    [session addInput:deviceInput];
    
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];

    [stillImageOutput setOutputSettings:outputSettings];

    [session addOutput:stillImageOutput];
    
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    [previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    CALayer *rootLayer = [cameraView layer];
    [rootLayer setMasksToBounds:YES];
    [previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:previewLayer];
    
    return session;
    
    bail:
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:[NSString stringWithFormat:@"Failed with error %d", (int)[error code]]
                                    message:[error localizedDescription]
                                    delegate:nil
                                    cancelButtonTitle:@"Dismiss"
                                    otherButtonTitles:nil];
        
        [alertView show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    photoState = NONE;
   
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)clickImage:(AVCaptureStillImageOutput *) stillImageOutput callback:(void (^)(UIImage *))completionBlock {
    AVCaptureConnection *videoConnection = nil;
    
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    NSLog(@"about to request a capture from: %@", stillImageOutput);
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection
                                                  completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         CFDictionaryRef exifAttachments = CMGetAttachment( imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments)
         {
             // Do something with the attachments.
             NSLog(@"attachements: %@", exifAttachments);
         }
         else
         {
             NSLog(@"no attachments");
         }
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[UIImage alloc] initWithData:imageData];
         
         completionBlock(image);
     }];
}

- (IBAction)mainButtonClicked:(id)sender {
    if (photoState == NONE)
    {
        cancelButton.hidden = false;

        [self clickImage:backCameraStillImageOutput callback:^(UIImage *image) {
            backImage = image;
            [backCameraSession stopRunning];
            [frontCameraSession startRunning];
        }];
        photoState = BACKCAM_DONE;
    }
    else if(photoState == BACKCAM_DONE)
    {
        [self clickImage:frontCameraStillImageOutput callback:^(UIImage *image) {
            frontImage = image;
            [frontCameraSession stopRunning];
            
            finalImage = [self addImage:backImage  secondImage:frontImage];
            [mainButton setTitle:@"SHARE" forState:UIControlStateNormal];
            addButton.hidden = false;

            photoState = FRONTCAM_DONE;
        }];
    }
    else if(photoState == FRONTCAM_DONE) {
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil);
        [self sendImageContentToWeixin:finalImage];

        photoState = SHARE_DONE;
        [self resetView];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self resetView];
}

- (IBAction)addButtonClicked:(id)sender {
    if(photoState == FRONTCAM_DONE) {
        UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil);
        [self showAutoHideDialog:@"Saved To Photos"];
    }
}

- (void) resetView {
    photoState = NONE;
    cancelButton.hidden = true;
    addButton.hidden = true;

    [mainButton setTitle:@"CLICK" forState:UIControlStateNormal];
    
    [backCameraSession stopRunning];
    [frontCameraSession stopRunning];
    
    [backCameraSession startRunning];
}

- (UIImage*)addImage:(UIImage *)image secondImage:(UIImage *)image2
{
    CGRect s = [[UIScreen mainScreen] bounds];
    CGSize is = CGSizeMake(s.size.width, s.size.height / 2);
    
    UIGraphicsBeginImageContext(s.size);
    
    image = [image imageByScalingAndCroppingForSize:is];
    image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:UIImageOrientationUp];
    [image drawInRect:CGRectMake(0, 0, is.width, is.height)];
    
    image2 = [image2 imageByScalingAndCroppingForSize:is];
    image2 = [UIImage imageWithCGImage:[image2 CGImage] scale:1.0 orientation:UIImageOrientationUpMirrored];
    [image2 drawInRect:CGRectMake(0, is.height , is.width, is.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void) sendImageContentToWeixin:(UIImage *)image {
    //if the Weixin app is not installed, show an error
    if (![WXApi isWXAppInstalled]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"The Weixin app is not installed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        return;
    }
    //create a message object
    WXMediaMessage *message = [WXMediaMessage message];
    
    //set the thumbnail image. This MUST be less than 32kb, or sendReq may return NO.
    //we'll just use the full image resized to 100x100 pixels for now
    [message setThumbImage:[image resizedImage:CGSizeMake(80,142) interpolationQuality:kCGInterpolationDefault]];
    [message setTitle:@"Enjoy this Moto. http://test.com/"];

    //create an image object and set the image data as a JPG representation of our UIImage
    WXImageObject *ext = [WXImageObject object];
    ext.imageData = UIImageJPEGRepresentation(image, 0.8);
    message.mediaObject = ext;
    
    //create a request
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    
    //this is a multimedia message, not a text message
    req.bText = NO;
    
    //set the message
    req.message = message;
    
    
    //set the "scene", WXSceneTimeline is for "moments". WXSceneSession allows the user to send a message to friends
    //req.scene = WXSceneSession;
    //req.scene = WXSceneTimeline;
    
    //try to send the request
    if (![WXApi sendReq:req]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)showAutoHideDialog:(NSString *) message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [alertView setBackgroundColor:[UIColor blackColor]];
    [alertView show];
    
    int64_t delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [alertView dismissWithClickedButtonIndex:0 animated:YES];

    });
}


- (void)fillLayer:(CALayer *)layer color:(UIColor *)color
{
        /*
    UIGraphicsBeginImageContext(layer.frame.size);

    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, layer.bounds);
    */
    
    /*
    layer.backgroundColor = [UIColor blueColor].CGColor;
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.shadowRadius = 5.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    layer.frame = CGRectMake(30, 30, 128, 192);
    */
    
    /*
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    */
}


@end
