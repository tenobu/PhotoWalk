//
//  SlideshowViewController.h
//  PhotoWalk
//
//  Created by ビザンコムマック０７ on 2014/10/27.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideshowViewController : UIViewController
- (IBAction)today:(id)sender;

- (IBAction)tag:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *imageview;

@end
