//
//  CustomAnnotation.m
//  MapEditor
//
//  Created by 寺内 信夫 on 2014/10/23.
//  Copyright (c) 2014年 ビザンコムマック０９. All rights reserved.
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation

- (MKAnnotationView *)annotationView
{

	MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation: self
																	reuseIdentifier: @"CustomAnnotation"];
	
	annotationView.enabled = YES;
	annotationView.canShowCallout = YES;
	annotationView.image = nil;
	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
	
	return annotationView;
	
}

- (void)setNo: (NSString *)no
{

	_no = no;
	
}

- (NSString *)no
{
	
	return _no;
	
}
@end
