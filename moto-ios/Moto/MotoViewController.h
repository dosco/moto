//
//  MotoViewController.h
//  Moto
//
//  Created by Vikram Rangnekar on 10/12/13.
//  Copyright (c) 2013 Vikram Rangnekar. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MotoViewController : UIViewController <UINavigationControllerDelegate> {
    
    IBOutlet UIButton *MyButton;
    
    IBOutlet UIButton *cancelButton;
    UIImageView *frontImageView;
    UIImageView *backImageView;
    
    UIImage *frontBackImage;
    NSInteger photoState;
    
}

typedef NS_ENUM(NSInteger, PhotoStateType) {
    NONE,
    FRONTCAM_DONE,
    BACKCAM_DONE
};

- (IBAction)MyButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;

@end
