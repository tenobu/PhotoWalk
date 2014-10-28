//
//  CameraViewController.h
//  PhotoWake
//
//  Created by 寺内 信夫 on 2014/10/26.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@interface CameraViewController : UIViewController < UINavigationControllerDelegate, UIImagePickerControllerDelegate, CLLocationManagerDelegate >

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *label_1;

- (IBAction)cameraButtonPressed:(id)sender;
- (IBAction)galleryButtonPressed:(id)sender;

@end
