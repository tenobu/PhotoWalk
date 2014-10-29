//
//  CameraViewController.m
//  PhotoWalk
//
//  Created by 寺内 信夫 on 2014/10/26.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "CameraViewController.h"

#import "AppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CustomAnnotation_Hata.h"
#import "CustomAnnotation_HataOk.h"
#import "CustomAnnotation_Photo.h"
#import "CustomAnnotation_GPS.h"
#import "CustomAnnotation_GPS_Old.h"

@interface CameraViewController ()
{
	
@private
	
	AppDelegate *app;
	
	UIImageView *pictureImage;
	
	CLLocationManager *locationManager;
	
	CLLocationCoordinate2D coordinate;
	
	CLLocationDegrees   latitude , latitude_G_Old , latitude_P_Old;
	CLLocationDegrees   longitude, longitude_G_Old, longitude_P_Old;
	CLLocationDirection heading;
	
	NSMutableArray *selecttag;
	NSArray *tagarray;

}

@end

@implementation CameraViewController

- (void)viewDidLoad
{

	[super viewDidLoad];
	
	app = [[UIApplication sharedApplication] delegate];
	
	[self initLocationManager];

	[self cameraButtonPressed: nil];

	
	self.upbtn.hidden = YES;
	self.tagbtn.hidden = YES;
	self.label2.hidden = YES;

	tagarray = [NSArray arrayWithObjects:@"野面積み",@"算木積み",@"曲輪",@"枡形",@"刻印石",@"矢穴跡",@"埋門",@"蜂須賀卍", @"緑色片岩（青石）",@"紅簾片岩（紫雲石）",@"織豊系城郭",@"阿波の大狸",@"上田宗箇",@"舌石",@"天正期の石垣",@"転用石",@"本丸",@"鷲の門",@"潮入り庭園",@"珍景",@"ベスト",@"海蝕痕",@"貝塚",@"8620形機関車",nil];

}

- (void)didReceiveMemoryWarning
{

	[super didReceiveMemoryWarning];

	// Dispose of any resources that can be recreated.

}

// GPS初期化
- (void)initLocationManager
{
	
	latitude_P_Old = longitude_P_Old = latitude_G_Old = longitude_G_Old = 9999;
	
	locationManager = [[CLLocationManager alloc] init];

//	if ( SYSTEM_VERSION_EQUAL_TO(v) == 8 ) {
//		
//	}
	[locationManager requestAlwaysAuthorization];
	
	locationManager.delegate = self;
	
	locationManager.distanceFilter  = kCLDistanceFilterNone;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
	if ( [CLLocationManager locationServicesEnabled] ) {
		
		[locationManager startUpdatingLocation];
		
	}
	
	if ( [CLLocationManager headingAvailable] ) {
		
		[locationManager startUpdatingHeading];
		
	}
	
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// 写真関連
- (void)imagePickerController: (UIImagePickerController *)picker
didFinishPickingMediaWithInfo: (NSDictionary *)info
{
	
	[self dismissViewControllerAnimated: YES
							 completion: NULL];
	
	UIImage *image = [info objectForKey: UIImagePickerControllerEditedImage];
	
	if ( image == nil ) {
	
		image = [info objectForKey: UIImagePickerControllerOriginalImage];
		
	}
	
	// Do something with the image
	[self.imageView setImage: image];
	
	ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
	
	[lib writeImageToSavedPhotosAlbum: image.CGImage
							 metadata: nil
					  completionBlock: ^( NSURL* url, NSError* error ) {
						  
						  NSLog(@"Saved: %@<%@>", url, error);
					  
					  }];

	
	app.bool_GPS_Old = YES;
	
	
	CLLocationDegrees lat = latitude;
	CLLocationDegrees lon = longitude;
	
	
	for ( CustomAnnotation_Hata *hata in app.array_Hata ) {
		
		CustomAnnotation_HataOk *ok = [self hataOk: hata.no];
		
		if ( ok == nil ) {
			
			float float_lat_1 = hata.coordinate.latitude  - 0.0004;
			float float_lat_2 = hata.coordinate.latitude  + 0.0004;
			float float_lon_1 = hata.coordinate.longitude - 0.0004;
			float float_lon_2 = hata.coordinate.longitude + 0.0004;
			
			if ( float_lat_1 < lat && lat < float_lat_2 &&
				 float_lon_1 < lon && lon < float_lon_2 ) {
			
				ok = [[CustomAnnotation_HataOk alloc] init];
				
				ok.coordinate  = hata.coordinate;
				ok.no          = hata.no;
				ok.title       = hata.title;
				ok.subtitle    = hata.subtitle;
				ok.explanation = hata.explanation;
				
				[app.array_HataOk addObject: ok];
				
				break;
				
			}
			
		}
		
	}

	
	if ( latitude_P_Old == 9999 && longitude_P_Old == 9999 ) {
		
		latitude_P_Old  = lat;
		longitude_P_Old = lon;
		
		[self addAnnotation_Photo];
		
	} else {
		
		CLLocationDegrees _lat = lat - latitude_P_Old;
		CLLocationDegrees _lon = lon - longitude_P_Old;
		
		if ( _lat < 0 ) _lat *= -1;
		if ( _lon < 0 ) _lon *= -1;
		
		// 0.00007, 0.0001
		if ( _lat > 0.0001 || _lon > 0.0001 ) {
			
			[self addAnnotation_Photo];
			[self addAnnotation_GPSOld];
			
			latitude  = latitude_P_Old  = latitude_G_Old  = lat;
			longitude = longitude_P_Old = longitude_G_Old = lon;
			
		}
		
	}
	
	selecttag = [NSMutableArray array];
	self.tagbtn.hidden = NO;
	self.upbtn.hidden = NO;
	self.label2.hidden = NO;
	self.label2.text = @"タグが選択されていません";

}

- (void)     locationManager: (CLLocationManager *)manager
didChangeAuthorizationStatus: (CLAuthorizationStatus)status
{
	
	if ( status == kCLAuthorizationStatusNotDetermined ) {
		// ユーザが位置情報の使用を許可していない
	}
	
}

- (void)locationManager: (CLLocationManager *)manager
	 didUpdateLocations: (NSArray *)locations
{
	
	CLLocation* location = [locations lastObject];
	
	CLLocationDegrees lat = location.coordinate.latitude;
	CLLocationDegrees lon = location.coordinate.longitude;

	
	self.label_1.text = [NSString stringWithFormat: @"coord = (%f,%f)", lat, lon];

	
	if ( latitude_G_Old == 9999 && longitude_G_Old == 9999 ) {
		
		latitude  = latitude_G_Old  = lat;
		longitude = longitude_G_Old = lon;
		
		[self setAnnotation_GPS];
		
	} else {

		if ( app.bool_GPS_Old ) {
			
			CLLocationDegrees _lat = lat - latitude_G_Old;
			CLLocationDegrees _lon = lon - longitude_G_Old;
			
			if ( _lat < 0 ) _lat *= -1;
			if ( _lon < 0 ) _lon *= -1;
			
			// 0.00007, 0.0001
			if ( _lat > 0.0001 || _lon > 0.0001 ) {
				
				CustomAnnotation_GPS *gps = [self annotation_GPS];
				
				[self addAnnotation_GPSOld];
				
				CustomAnnotation_GPS_Old *gps_old = [self lastAnnotation_GPSOld];
				
				gps_old.coordinate = gps.coordinate;
				
				latitude  = latitude_G_Old  = lat;
				longitude = longitude_G_Old = lon;
				
				gps.coordinate = CLLocationCoordinate2DMake( latitude, longitude );
				
				NSLog( @"GPS Old" );
				
			}

		}
		
	}
	
}

- (void)locationManager: (CLLocationManager *)manager
	   didFailWithError: (NSError *)error
{
	
	
}

- (void)locationManager: (CLLocationManager *)manager
	   didUpdateHeading: (CLHeading *)newHeading
{
	
	heading = newHeading.trueHeading;
	
}

- (void) addAnnotation_Photo
{
	
	CustomAnnotation_Photo *ca = [[CustomAnnotation_Photo alloc] init];
	
	ca.coordinate  = CLLocationCoordinate2DMake( latitude, longitude );// 34.074, 134.554 );

	ca.title       = @"写真の撮影場所";
	ca.subtitle    = [NSString stringWithFormat: @"%f, %f", latitude, longitude];
	ca.explanation = @"";
	
//	[app.array_Photo_Add addObject: ca];
	[app.array_Photo addObject: ca];
	
}

- (void)setAnnotation_GPS
{
	
	CustomAnnotation_GPS *ca = app.array_GPS[0];
	
	ca.coordinate  = CLLocationCoordinate2DMake( latitude, longitude );// 34.076, 134.557 );
	ca.title       = @"自分の現在位置";
	ca.subtitle    = [NSString stringWithFormat: @"%f, %f", latitude, longitude];
	ca.explanation = @"";
	
//	[app.array_GPSOld_Add addObject: ca];
//	[app.array_GPSOld addObject: ca];
	
}

- (CustomAnnotation_GPS *)annotation_GPS
{
	
	return app.array_GPS[0];
	
}

- (void)addAnnotation_GPSOld
{
	
	CustomAnnotation_GPS_Old *ca = [[CustomAnnotation_GPS_Old alloc] init];
	
	ca.coordinate  = CLLocationCoordinate2DMake( latitude, longitude );// 34.074, 134.554 );
	ca.title       = @"Tokyo Tower";
	ca.subtitle    = @"opening in Dec 1958";
	ca.explanation = @"34.074, 134.556";
	
	CustomAnnotation_GPS_Old *cao = [app.array_GPSOld lastObject];
	if ( cao ) {
		
		CLLocationCoordinate2D coordinate1, coordinate2;
		coordinate1 = coordinate2 = cao.coordinate;
		
		coordinate1.latitude  -= 0.0001;
		coordinate2.latitude  += 0.0001;
		
		coordinate1.longitude -= 0.0001;
		coordinate2.longitude += 0.0001;
		
		if ( coordinate1.latitude  < ca.coordinate.latitude  && ca.coordinate.latitude  < coordinate2.latitude &&
			 coordinate1.longitude < ca.coordinate.longitude && ca.coordinate.longitude < coordinate2.longitude ) return;
		
	}
	
//	[app.array_GPSOld_Add addObject: ca];
	[app.array_GPSOld addObject: ca];
	
}

- (CustomAnnotation_GPS_Old *)lastAnnotation_GPSOld
{
	
//	return [app.array_GPSOld_Add lastObject];
	return [app.array_GPSOld lastObject];
	
}

- (CustomAnnotation_HataOk *)hataOk: (NSString *)no
{

	for ( CustomAnnotation_HataOk *ok in app.array_HataOk) {

		if ( [ok.no isEqualToString: no] ) {
			
			return ok;
			
		}
		
	}
	
	return nil;
	
}

- (IBAction)libraryButtonTouched: (id)sender
{
	
	if ( [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary] ) {
		
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		
		[imagePickerController setSourceType   : UIImagePickerControllerSourceTypePhotoLibrary];
		[imagePickerController setAllowsEditing: YES];
		
		imagePickerController.delegate = self;
		
		[self presentViewController: imagePickerController
						   animated: YES
						 completion: nil];
		
		// iPadの場合はUIPopoverControllerを使う
		//		popover = [[UIPopoverController alloc]initWithContentViewController:imagePickerController];
		//		[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
	} else {
		
		NSLog( @"photo library invalid." );
		
	}
	
}

- (IBAction)cameraButtonPressed: (id)sender
{
	
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	
	if ( [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera] ) {
		
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePickerController.mediaTypes = @[ (NSString *)kUTTypeImage ];
		imagePickerController.delegate = self;
		
		[self presentViewController: imagePickerController
						   animated: YES
						 completion: NULL];
		
	} else {
		
		// camera not available, do something
		
	}
	
}

- (IBAction)galleryButtonPressed: (id)sender
{
	
	UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
	
	if ( [UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary] ) {
		
		pickerController.sourceType    = UIImagePickerControllerSourceTypePhotoLibrary;
		pickerController.allowsEditing = YES;
		pickerController.delegate      = self;
		
		[self presentViewController: pickerController
						   animated: YES
						 completion: NULL];
		
	}
	
}

- (IBAction)tagadd:(id)sender {
	//アクションシートの変数を生成
	UIActionSheet *as = [[UIActionSheet alloc]init];
	//アクションシートのタイトルを設定
	as.title = @"タグを選んでください";
	//アクションシートのデリゲートを自分自身に設定
	as.delegate = self;
	//tagarrayの要素数の繰り返し処理実行
	for (int i = 0; i < [tagarray count]; i++) {
		//追加するボタンのタイトルをtagarrayのi番目の要素に設定
		[as addButtonWithTitle:[tagarray objectAtIndex:i]];
	}
	//アクションシートを表示
	[as showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	//選択したタグの名前を格納する変数
	NSString *tag = [tagarray objectAtIndex:buttonIndex];
	//もうすでに選択されているか
	if ([selecttag containsObject:tag]) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"警告"
							  message:@"このタグはもう選択されています"
							  delegate:self
							  cancelButtonTitle:nil
							  otherButtonTitles:@"OK", nil];
		[alert show];
	}
	//選択したタグが5個以下か
	else if ([selecttag count]<5) {
		//タグを追加
		[selecttag addObject:tag];
		self.label2.text = @"選択したタグ\n";
		for (int i = 0; i<[selecttag count]; i++) {
			self.label2.text = [self.label2.text stringByAppendingString:[selecttag objectAtIndex:i]];
			if (i < [selecttag count] - 1) {
				self.label2.text = [self.label2.text stringByAppendingString:@"\n"];
			}
		}
	}else{
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"警告"
							  message:@"タグは5つまでしか選択されません"
							  delegate:self
							  cancelButtonTitle:nil
							  otherButtonTitles:@"OK", nil];
		[alert show];
	}
	
}

- (IBAction)upload:(id)sender {
	
	//    longitude
	NSString *tagstr = self.label2.text;
	self.tagbtn.hidden = YES;
	self.upbtn.hidden = YES;
	UIImage *img = self.imageView.image;
	NSData *imgdata =
	UIImageJPEGRepresentation(img, 1.0f);
	NSString *dvid = [UIDevice currentDevice].identifierForVendor.UUIDString;
	NSString *urlstr = @"http://smartshinobu.miraiserver.com/tokushima/idadd.php?iphoneid=";
	NSLog(@"%@",dvid);
	urlstr = [urlstr stringByAppendingString:dvid];
	NSURL *url = [NSURL URLWithString:urlstr];
	//リクエスト生成
	NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
	//レスポンスを生成
	NSHTTPURLResponse *response;
	//NSErrorの初期化
	NSError *err = nil;
	//requestによって返ってきたデータを生成
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
	NSString *datastr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"%@",datastr);
	//写真のデータ50000バイトより小さくするようにする
	while (imgdata.length > 50000) {
		//圧縮率0.7で圧縮
		imgdata = UIImageJPEGRepresentation(img, 0.7f);
		
		img = [[UIImage alloc]initWithData:imgdata];
		if (imgdata.length <= 50000) {
			break;
		}
		//サイズ7割にする
		CGSize cs = CGSizeMake(img.size.width*0.7, img.size.height*0.7);
		UIGraphicsBeginImageContext(cs);
		[img drawInRect:CGRectMake(0, 0, cs.width, cs.height)];
		img = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	self.label2.text = @"写真を送信中";
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSURL *url = [NSURL URLWithString:@"http://smartshinobu.miraiserver.com/tokushima/file.php"];
		NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
		NSMutableData *body = [NSMutableData data];
		NSString *boundary = @"--1680ert52491z";
		NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
		[request setHTTPMethod:@"POST"];
		//iphoneidのパラメータの設定
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Disposition: form-data; name=\"iphoneid\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"%@\r\n", dvid] dataUsingEncoding:NSUTF8StringEncoding]];
		//latのパラメータの設定
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Disposition: form-data; name=\"lat\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		NSString *lat = [NSString stringWithFormat:@"%f",latitude];
		[body appendData:[[NSString stringWithFormat:@"%@\r\n", lat] dataUsingEncoding:NSUTF8StringEncoding]];
		//lngのパラメータの設定
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Disposition: form-data; name=\"lng\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		NSString *lng = [NSString stringWithFormat:@"%f",longitude];
		[body appendData:[[NSString stringWithFormat:@"%@\r\n", lng] dataUsingEncoding:NSUTF8StringEncoding]];
		//タグを選択したかどうか
		if ([selecttag count] > 0) {
			//tagのパラメータの設定
			[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
			[body appendData:[@"Content-Disposition: form-data; name=\"tag\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			NSString *tagstr2 = [tagstr stringByReplacingOccurrencesOfString:@"選択したタグ\n" withString:@""];
			NSLog(@"%@",tagstr2);
			[body appendData:[[NSString stringWithFormat:@"%@\r\n", tagstr2] dataUsingEncoding:NSUTF8StringEncoding]];
		}
		//imageのパラメータの設定
		[body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"2.jpg\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:imgdata];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[request addValue:contentType forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:body];
		NSURLResponse *response;
		NSError *err = nil;
		NSData *data2 = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
		NSString *datastr2 = [[NSString alloc]initWithData:data2 encoding:NSUTF8StringEncoding];
		NSLog(@"%@",datastr2);
		dispatch_async(dispatch_get_main_queue(), ^{
			self.label2.text = @"アップロード完了";
		});
	});
}

@end
