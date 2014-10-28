//
//  CustomAnnotation.h
//  MapEditor
//
//  Created by 寺内 信夫 on 2014/10/23.
//  Copyright (c) 2014年 ビザンコムマック０９. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject < MKAnnotation >
{

@protected

	NSString *_no;
	
}

@property (readwrite, nonatomic) CLLocationCoordinate2D coordinate; // required

@property (readwrite, nonatomic, strong) NSString *no;
@property (readwrite, nonatomic, strong) NSString *title; // optional
@property (readwrite, nonatomic, strong) NSString *subtitle; // ditto
@property (readwrite, nonatomic, strong) NSString *explanation; // for example

- (MKAnnotationView *)annotationView;

@end
