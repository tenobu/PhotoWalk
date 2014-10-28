//
//  AppDelegate.m
//  PhotoWake
//
//  Created by 寺内 信夫 on 2014/10/24.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "AppDelegate.h"

#import "CustomAnnotation_Hata.h"
#import "CustomAnnotation_HataOk.h"
#import "CustomAnnotation_Photo.h"
#import "CustomAnnotation_GPS.h"
#import "CustomAnnotation_GPS_Old.h"

@interface AppDelegate ()
{

@private

	NSMutableData *receivedData;
	
}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

	// Override point for customization after application launch.

	[self loadAnnotation_Hara];
	[self loadAnnotation_Photo];
	[self initAnnotation_GPS];
	[self initAnnotation_GPSOld];
	
	return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)loadAnnotation_Hara
{
	
	self.array_Hata   = [[NSMutableArray alloc] init];
	self.array_HataOk = [[NSMutableArray alloc] init];
	
	NSURL *url = [NSURL URLWithString:@"http://smartshinobu.miraiserver.com/tokushima/placetitle.php"];
	
	NSURLRequest       *request = [[NSURLRequest alloc] initWithURL: url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request
																  delegate: self];
	
	// 作成に失敗する場合には、リクエストが送信されないので
	// チェックする
	if ( ! connection ) {
		
		NSLog(@"connection error.");
	
	}
	
}

- (void)loadAnnotation_Photo
{
	
	self.array_Photo     = [[NSMutableArray alloc] init];
	self.array_Photo_Add = [[NSMutableArray alloc] init];
	
}

- (void)initAnnotation_GPS
{
	
	self.array_GPS = [[NSMutableArray alloc] init];
	
}

- (void)initAnnotation_GPSOld
{
	
	self.array_GPSOld     = [[NSMutableArray alloc] init];
	self.array_GPSOld_Add = [[NSMutableArray alloc] init];
	
}

// データ受信時に１回だけ呼び出される。
// 受信データを格納する変数を初期化する。
- (void) connection: (NSURLConnection *)connection
 didReceiveResponse: (NSURLResponse *)response
{
	
	// receiveDataはフィールド変数
	receivedData = [[NSMutableData alloc] init];

}

// データ受信したら何度も呼び出されるメソッド。
// 受信したデータをreceivedDataに追加する
- (void) connection: (NSURLConnection *)connection
	 didReceiveData: (NSData *)data
{

	[receivedData appendData:data];

}

// データ受信が終わったら呼び出されるメソッド。
- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
	
	// 今回受信したデータはHTMLデータなので、NSDataをNSStringに変換する。
	NSString *str = [[NSString alloc] initWithBytes: receivedData.bytes
											  length: receivedData.length
											encoding: NSUTF8StringEncoding];

	str = [str stringByReplacingOccurrencesOfString: @"<!--/* Miraiserver \"NO ADD\" http://www.miraiserver.com */-->"
										 withString: @""];
	str = [str stringByReplacingOccurrencesOfString: @"<script type=\"text/javascript\" src=\"http://17787372.ranking.fc2.com/analyze.js\" charset=\"utf-8\"></script>"
										 withString: @""];

	NSData *trimdata = [str dataUsingEncoding:NSUTF8StringEncoding];

	NSError *error;
	NSArray *array = [NSJSONSerialization JSONObjectWithData: trimdata
													 options: NSJSONReadingMutableContainers
													   error: &error];

	if ( error ) {
		
		NSLog( @"%@", error );
		
		return;
		
	}
	
	NSMutableArray *array_sort = [[NSMutableArray alloc] init];
	
	for ( NSDictionary *dic in array ) {
	
		NSMutableDictionary *dic_sort = [[NSMutableDictionary alloc] init];
		
		NSString *str_no = [dic objectForKey: @"id"];
		NSString *str_id = [dic objectForKey: @"id"];
		if ( [str_id length] == 1 ) {
			str_id = [NSString stringWithFormat: @"0%@", str_id];
		}
		
		NSString *title = [dic objectForKey: @"title"];
		title = [NSString stringWithFormat: @"%@、%@", str_no, title];
		
		[dic_sort setValue: str_no                          forKey: @"no"];
		[dic_sort setValue: str_id                          forKey: @"id"];
		[dic_sort setValue: title                           forKey: @"title"];
		[dic_sort setValue: [dic objectForKey: @"subtitle"] forKey: @"subtitle"];
		[dic_sort setValue: [dic objectForKey: @"lat"]      forKey: @"lat"];
		[dic_sort setValue: [dic objectForKey: @"lng"]      forKey: @"lng"];
	
		[array_sort addObject: dic_sort];
		
	}
	
	NSSortDescriptor *sortDescNumber = [[NSSortDescriptor alloc] initWithKey: @"id"
																   ascending: YES];

	NSArray *sortDescArray = [NSArray arrayWithObjects: sortDescNumber, nil];

	[array_sort sortUsingDescriptors: sortDescArray];
	

	NSMutableArray *array_hata = [[NSMutableArray alloc] init];
	
	for ( NSDictionary *dic in array_sort ) {
		
		NSString *str_lat = [dic objectForKey: @"lat"];
		NSString *str_lng = [dic objectForKey: @"lng"];
		
		float float_lat = str_lat.floatValue;
		float float_lng = str_lng.floatValue;
		
		CustomAnnotation_Hata *ca = [[CustomAnnotation_Hata alloc] init];
		
		ca.coordinate  = CLLocationCoordinate2DMake( float_lat, float_lng );
		ca.no          = [dic objectForKey: @"no"];
		ca.title       = [dic objectForKey: @"title"];
		ca.subtitle    = [dic objectForKey: @"subtitle"];
		ca.explanation = [NSString stringWithFormat: @"%@, %@", str_lat, str_lng];
		
		[array_hata addObject: ca];

		if ( [ca.no isEqualToString: @"1"] ) {
			
			CustomAnnotation_HataOk *ca = [[CustomAnnotation_HataOk alloc] init];
			
			ca.coordinate  = CLLocationCoordinate2DMake( float_lat, float_lng );
			ca.no          = [dic objectForKey: @"no"];
			ca.title       = [dic objectForKey: @"title"];
			ca.subtitle    = [dic objectForKey: @"subtitle"];
			ca.explanation = [NSString stringWithFormat: @"%@, %@", str_lat, str_lng];
			
			[self.array_HataOk addObject: ca];

		}
		
	}
	
	[self.array_Hata addObjectsFromArray: array_hata];
	
}

- (void)connection: (NSURLConnection *)connection
  didFailWithError: (NSError *)error
{

	// エラー情報を表示する。
	// objectForKeyで指定するKeyがポイント
	NSLog(@"Connection failed! Error - %@ %@",
		  [error localizedDescription],
		  [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);

}

@end
