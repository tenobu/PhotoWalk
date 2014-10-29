//
//  CameraViewController.h
//  PhotoWalk
//
//  Created by 寺内 信夫 on 2014/10/26.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@interface CameraViewController : UIViewController < UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate, UIActionSheetDelegate >

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *label_1;

@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UIButton *upbtn;
@property (weak, nonatomic) IBOutlet UIButton *tagbtn;

- (IBAction)cameraButtonPressed:(id)sender;
- (IBAction)galleryButtonPressed:(id)sender;

- (IBAction)upload:(id)sender;
- (IBAction)tagadd:(id)sender;

@end
