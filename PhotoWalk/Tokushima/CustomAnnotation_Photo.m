//
//  CustomAnnotation_Photo.m
//  MapEditor
//
//  Created by 寺内 信夫 on 2014/10/23.
//  Copyright (c) 2014年 ビザンコムマック０９. All rights reserved.
//

#import "CustomAnnotation_Photo.h"

@implementation CustomAnnotation_Photo

- (MKAnnotationView *)annotationView
{
	
	MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation: self
																	reuseIdentifier: @"CustomAnnotation_Photo"];
	
	annotationView.enabled = YES;
	annotationView.canShowCallout = YES;
	annotationView.image = [UIImage imageNamed: @"Photo.png"];
	annotationView.frame = CGRectMake( 0, 0, 25, 30 );
	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
	
	return annotationView;
	
}

@end
