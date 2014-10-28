//
//  CustomAnnotation_HataOk.m
//  PhotoWalk
//
//  Created by 寺内 信夫 on 2014/10/28.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "CustomAnnotation_HataOk.h"

@implementation CustomAnnotation_HataOk

- (MKAnnotationView *)annotationView
{
	
	MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation: self
																	reuseIdentifier: @"CustomAnnotation_HataOk"];
	
	annotationView.enabled = NO;
	annotationView.canShowCallout = NO;
	annotationView.image = [UIImage imageNamed: @"HataOk.png"];
	annotationView.frame = CGRectMake( 0, 0, 35, 35 );
	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
	
	return annotationView;
	
}

@end
