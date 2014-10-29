//
//  HataViewController.m
//  PhotoWalk
//
//  Created by 寺内 信夫 on 2014/10/26.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "HataViewController.h"

#import "CustomAnnotation_Hata.h"
#import "CellViewCell.h"
#import "TextViewCell.h"
#import "PhotoViewCell.h"

@interface HataViewController ()
{
	
@private
	
	CustomAnnotation_Hata *hata;
	
	NSURLConnection *connectionFile;
	NSURLConnection *connectionData;
	
	NSMutableData *receivedFile;
	NSMutableData *receivedData;
	
	NSString *string_NoTitle, *string_Subtitle, *string_LatLng;
	
	NSMutableArray *array_Data;
	NSMutableArray *array_Photo;
	
}

@end

@implementation HataViewController

- (void)viewDidLoad
{

	[super viewDidLoad];
    

	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	NSString *string_no = [ud objectForKey: @"Hata Data No"];
	
	
	string_NoTitle = string_Subtitle = string_LatLng = @"";
	
	array_Data  = [[NSMutableArray alloc] init];
	array_Photo = [[NSMutableArray alloc] init];
	
	
	self.tableView.delegate = self;
	
	self.navigationItem.title = string_no;
	
	[self callHataData: string_no];
	
}

- (void)didReceiveMemoryWarning {

	[super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (void)callHataData: (NSString *)str_no
{
	
	NSString *command = [NSString stringWithFormat:
						 @"http://smartshinobu.miraiserver.com/tokushima/oneplacetitle.php?id=%@", str_no];
	NSURL *url = [NSURL URLWithString: command];
	
	NSURLRequest    *request        = [[NSURLRequest alloc] initWithURL: url];
	connectionFile = [[NSURLConnection alloc] initWithRequest: request
													 delegate: self];
	
	if ( ! connectionFile ) {
		
		NSLog(@"connection error.");
		
	}
	
	command = [NSString stringWithFormat:
			   @"http://smartshinobu.miraiserver.com/tokushima/oneplaceimage.php?id=%@", str_no];
	url = [NSURL URLWithString: command];
	
	request        = [[NSURLRequest alloc] initWithURL: url];
	connectionData = [[NSURLConnection alloc] initWithRequest: request
													 delegate: self];
	
	if ( ! connectionData ) {
		
		NSLog(@"connection error.");
		
	}
	
}

- (void)callPhotoData: (NSString *)filename
{
	
	NSMutableDictionary *dic;
	BOOL flag = NO;
	
	for ( dic in array_Photo ) {
	 
		if ( [[dic objectForKey: @"filename"] isEqualToString: filename] ) {
			
			flag = YES;
		
			break;
			
		}
		
	}
	
	if ( [[dic objectForKey: @"filename"] isEqualToString: filename] == NO ) {
		
		dic = [[NSMutableDictionary alloc] init];
		
		[dic setValue: filename forKey: @"filename"];
		
		NSMutableData *data = [[NSMutableData alloc] init];
		[dic setValue: data     forKey: @"data"];
		
		[array_Photo addObject: dic];
		
	}
	
	NSURL *url = [NSURL URLWithString: filename];
	
	NSURLRequest    *request    = [[NSURLRequest alloc] initWithURL: url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request
																  delegate: self];
	
	if ( ! connection ) {
		
		NSLog(@"connection error.");

		return;
		
	}
	
	[dic setValue: connection forKey: @"connection"];
	
}

- (void) connection: (NSURLConnection *)connection
 didReceiveResponse: (NSURLResponse *)response
{

	if ( connection == connectionFile ) {
		
		receivedFile = [[NSMutableData alloc] init];

	} else if ( connection == connectionData ) {
		
		receivedData = [[NSMutableData alloc] init];
		
	} else {
		
		NSURLConnection *connection_photo;
		
		for ( NSDictionary *dic in array_Photo ) {
			
			connection_photo = [dic objectForKey: @"connection"];
			
			if ( connection_photo == connection ) {
				
				NSMutableData *photo_data = [[NSMutableData alloc] init];
				
				[dic setValue: photo_data forKey: @"data"];

			}
			
		}
		
	}
	
}

- (void) connection: (NSURLConnection *)connection
	 didReceiveData: (NSData *)data
{
	
	if ( connection == connectionFile ) {
		
		[receivedFile appendData: data];
		
	} else if ( connection == connectionData ) {
		
		[receivedData appendData: data];
		
	} else {
		
		NSURLConnection *connection_photo;
		
		for ( NSDictionary *dic in array_Photo ) {
			
			connection_photo = [dic objectForKey: @"connection"];
			
			if ( connection_photo == connection ) {
				
				NSMutableData *photo_data = [dic objectForKey: @"data"];
				
				[photo_data appendData: data];
			
				return;
				
			}
			
		}
		
		NSLog( @"- (void) connection: (NSURLConnection *)connection didReceiveData: (NSData *)data Error !!" );
		
	}

}

- (void) connectionDidFinishLoading: (NSURLConnection *)connection
{
	
	NSURLConnection *connection_photo;
	NSMutableDictionary *photo_dic;
	
	NSString *str;

	if ( connection == connectionFile ) {
		
		str = [[NSString alloc] initWithBytes: receivedFile.bytes
									   length: receivedFile.length
									 encoding: NSUTF8StringEncoding];

	} else if ( connection == connectionData ) {
		
		str = [[NSString alloc] initWithBytes: receivedData.bytes
									   length: receivedData.length
									 encoding: NSUTF8StringEncoding];
		
	} else {
		
		for ( photo_dic in array_Photo ) {
			
			connection_photo = [photo_dic objectForKey: @"connection"];
			
			if ( connection_photo == connection ) {
				
				NSMutableData *photo_data = [photo_dic objectForKey: @"data"];
				
				UIImage *image = [UIImage imageWithData: photo_data];
				
				[photo_dic setValue: image forKey: @"photo"];
				
				[self.tableView reloadData];

				return;
				
			}
			
		}
		
	}
	
	if ( str ) {
		
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

		if ( connection == connectionFile ) {
			
			NSDictionary *dic = [array objectAtIndex: 0];
			
			NSString *no    = [dic objectForKey: @"id"];
			NSString *title = [dic objectForKey: @"title"];
			string_NoTitle  = [NSString stringWithFormat: @"%@、%@", no, title];
			
			string_Subtitle = [dic objectForKey: @"subtitle"];
			
			NSString *lat   = [dic objectForKey: @"lat"];
			NSString *lng   = [dic objectForKey: @"lng"];
			string_LatLng   = [NSString stringWithFormat: @"( %@, %@ )", lat, lng];
			
	
		} else if ( connection == connectionData ) {
			
			[array_Data removeAllObjects];
			
			for ( NSDictionary *dic in array ) {
				
				[array_Data addObject: dic];
				
				[self callPhotoData: [dic objectForKey: @"filename"]];
			
			}
			
		}
		
		[self.tableView reloadData];

	}
	
	
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

	return 1;
	
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

	if ( [array_Data count] == 0 ) {
		
		return 2;
		
	} else {
	
		return 2 + 1 + [array_Photo count];
		
	}
	
}

- (UITableViewCell *)tableView: (UITableView *)tableView
		 cellForRowAtIndexPath: (NSIndexPath *)indexPath
{

	NSInteger row = indexPath.row;
	
	if ( row == 0 ) {
		
		CellViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CellViewCell"
															 forIndexPath: indexPath];
		
		cell.textLabel.text = string_Subtitle;

		return cell;
		
	} else if ( row == 1 ) {
		
		CellViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"CellViewCell"
															 forIndexPath: indexPath];

		cell.textLabel.text = string_LatLng;

		return cell;

	} else if ( row == 2 ) {
		
		for ( NSDictionary *dic in array_Data ) {
		
			//[self callPhotoData: [dic objectForKey: @"filename"]];
			
			TextViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"TextViewCell"
																 forIndexPath: indexPath];
			
			cell.textLabel.text = [dic objectForKey: @"description"];
			
			return cell;

		}
		
	} else {
		
		NSInteger index = row - 3;
		
		NSDictionary *dic = [array_Photo objectAtIndex: index];
		
		PhotoViewCell *cell = [tableView dequeueReusableCellWithIdentifier: @"PhotoViewCell"
															  forIndexPath: indexPath];
		
		cell.imageView_Photo.image = [dic objectForKey: @"photo"];
		
		cell.imageView_Photo.contentMode = UIViewContentModeScaleAspectFit;
		
		return cell;

	}

	return nil;
	
}

- (CGFloat)   tableView: (UITableView *)tableView
heightForRowAtIndexPath: (NSIndexPath *)indexPath
{
	
	NSInteger row = indexPath.row;
	
//	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: indexPath];

	if ( row < 2 ) {
		
		return 44;
		
	} else if ( row == 2 ) {

		return 114;
		
	} else {

////		PhotoViewCell *cell = (PhotoViewCell *)[tableView cellForRowAtIndexPath: indexPath];
//
//		CGFloat height = cell.frame.size.height;// cell.imageView_Photo.bounds.size.height + 10;
//		
//		return height;
		
//		CGRect bounds = cell.bounds;
//		bounds.size.width = tableView.bounds.size.width;
//		
//		cell.bounds = bounds;
//		
//		[cell setNeedsLayout];
//		[cell layoutIfNeeded];
//		
//		cell.pre
//		return [cell preservesSuperviewLayoutMargins

		return 300;
		
	}
	

}

- (CGFloat)            tableView: (UITableView *)tableView
estimatedHeightForRowAtIndexPath: (NSIndexPath *)indexPath
{
	
	return UITableViewAutomaticDimension;

}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
