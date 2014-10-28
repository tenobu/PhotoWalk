//
//  CustomAnnotation_GPS_Old.m
//  PhotoWake
//
//  Created by 寺内 信夫 on 2014/10/24.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "CustomAnnotation_GPS_Old.h"

@implementation CustomAnnotation_GPS_Old

- (MKAnnotationView *)annotationView
{
	
	MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation: self
																	reuseIdentifier: @"CustomAnnotation_GPS_Old"];
	
	annotationView.enabled = YES;
	annotationView.canShowCallout = NO;
	annotationView.image = [UIImage imageNamed: @"GPS_Old.png"];
	annotationView.frame = CGRectMake( 0, 0, 10, 10 );
	annotationView.rightCalloutAccessoryView = nil;// [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
	
	return annotationView;
	
}

@end
