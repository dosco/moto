//
//  MotoViewController.h
//  Moto
//
//  Created by Vikram Rangnekar on 10/12/13.
//  Copyright (c) 2013 Vikram Rangnekar. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MotoViewController : UIViewController <UINavigationControllerDelegate> {
    
    IBOutlet UIButton *shareAppButton;
    IBOutlet UIButton *mainButton;
    IBOutlet UIButton *cancelButton;
    IBOutlet UIButton *addButton;
    
    UIImageView *frontImageView;
    UIImageView *backImageView;
    
    UIImage *frontBackImage;
    NSInteger photoState;
    
}

typedef NS_ENUM(NSInteger, PhotoStateType) {
    NONE,
    FRONTCAM_DONE,
    BACKCAM_DONE,
    SHARE_DONE
};

- (IBAction)shareAppButtonClicked:(id)sender;
- (IBAction)mainButtonClicked:(id)sender;
- (IBAction)cancelButtonClicked:(id)sender;
- (IBAction)addButtonClicked:(id)sender;


@end
