//
//  CustomAnnotation_Hata.m
//  MapEditor
//
//  Created by ビザンコムマック０９ on 2014/10/23.
//  Copyright (c) 2014年 ビザンコムマック０９. All rights reserved.
//

#import "CustomAnnotation_Hata.h"

@implementation CustomAnnotation_Hata

- (MKAnnotationView *)annotationView
{
	
	MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation: self
																	reuseIdentifier: @"CustomAnnotation_Hata"];
	
	annotationView.enabled = YES;
	annotationView.canShowCallout = YES;
	annotationView.image = [UIImage imageNamed: @"Hata.png"];
	annotationView.frame = CGRectMake( 0, 0, 20, 30 );
	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType: UIButtonTypeDetailDisclosure];
	
	return annotationView;
	
}

@end
