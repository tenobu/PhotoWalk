//
//  HataViewController.m
//  PhotoWalk
//
//  Created by 寺内 信夫 on 2014/10/26.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "HataViewController.h"

#import "CustomAnnotation_Hata.h"

@interface HataViewController ()
{
	
@private
	
	CustomAnnotation_Hata *hata;
	
	NSMutableData *receivedData;
	
}

@end

@implementation HataViewController

- (void)viewDidLoad
{

	[super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	
	NSString *string_no = [ud objectForKey: @"Hata Data No"];
	
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
	
	NSURLRequest       *request = [[NSURLRequest alloc] initWithURL: url];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: request
																  delegate: self];
	
	// 作成に失敗する場合には、リクエストが送信されないので
	// チェックする
	if ( ! connection ) {
		
		NSLog(@"connection error.");
		
	}
	
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
	
	[receivedData appendData: data];
	
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
	
	NSDictionary *dic = [array objectAtIndex: 0];

	NSString *no       = [dic objectForKey: @"no"];
	NSString *title    = [dic objectForKey: @"title"];
	NSString *subtitle = [dic objectForKey: @"subtitle"];
	NSString *lat      = [dic objectForKey: @"lat"];
	NSString *lng      = [dic objectForKey: @"lng"];

	self.navigationController.title = [NSString stringWithFormat: @"%@、%@", no, title];
	
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
