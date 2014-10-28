//
//  CustomAnnotation_GPS.m
//  PhotoWake
//
//  Created by 寺内 信夫 on 2014/10/24.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "CustomAnnotation_GPS.h"

@implementation CustomAnnotation_GPS

- (MKAnnotationView *)annotationView
{
	
	MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation: self
																	reuseIdentifier: @"CustomAnnotation_GPS"];
	
	annotationView.enabled = YES;
	annotationView.canShowCallout = YES;
	annotationView.image = [UIImage imageNamed: @"GPS.png"];
	annotationView.frame = CGRectMake( 0, 0, 60, 60 );
	annotationView.rightCalloutAccessoryView = nil;// [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
	
	return annotationView;
	
}

@end
