//
//  AppDelegate.h
//  PhotoWake
//
//  Created by 寺内 信夫 on 2014/10/24.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

@interface AppDelegate : UIResponder < UIApplicationDelegate >
{
	
@private
		
}

@property (strong, nonatomic) UIWindow *window;

@property NSMutableArray *array_Hata;
@property NSMutableArray *array_HataOk;
@property NSMutableArray *array_Photo;
@property NSMutableArray *array_Photo_Add;
@property NSMutableArray *array_GPS;
@property NSMutableArray *array_GPSOld;
@property NSMutableArray *array_GPSOld_Add;

@end

