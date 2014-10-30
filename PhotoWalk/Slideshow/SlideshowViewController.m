//
//  SlideshowViewController.m
//  PhotoWalk
//
//  Created by ビザンコムマック０７ on 2014/10/27.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//B2E98F01-A5F5-427A-8ED3-62C4C2255E21
//225C7AE2-6AC8-4214-B975-9FC72A57AD00

#import "SlideshowViewController.h"

@interface SlideshowViewController ()<UIActionSheetDelegate>{
    //タグを格納するため配列
    NSArray *tagarray;
    //写真の名前を格納するための配列
    NSArray *imgarray;
    //スライドショーを行うために使われるタイマー変数
    NSTimer *timer;
    //スライドショーに使う写真の枚数をカウントするために使われる変数
    int count;
}

@end

@implementation SlideshowViewController

- (void)viewDidLoad {
    //tagarrayの初期化
    tagarray = [NSArray arrayWithObjects:@"野面積み",@"算木積み",@"曲輪",@"枡形",@"刻印石",@"矢穴跡",@"埋門",@"蜂須賀卍", @"緑色片岩（青石）",@"紅簾片岩（紫雲石）",@"織豊系城郭",@"阿波の大狸",@"上田宗箇",@"舌石",@"天正期の石垣",@"転用石",@"本丸",@"鷲の門",@"潮入り庭園",@"珍景",@"ベスト",@"海蝕痕",@"貝塚",@"8620形機関車",nil];
    self.label.hidden = YES;
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//今日というボタンを押されたときに呼ばれるメソッド
- (IBAction)today:(id)sender {
    //端末のIDを表す文字列を格納
//    NSString *dvid = (NSString*)[UIDevice currentDevice].identifierForVendor;
	NSString *dvid = [UIDevice currentDevice].identifierForVendor.UUIDString;
	NSLog(@"%@",dvid);
    //今日取った写真の名前の配列を取得するためのURLを表す文字列を格納
//	NSString *urlstr = @"http://smartshinobu.miraiserver.com/tokushima/historyphoto.php?iphoneid=";
	NSString *urlstr = @"http://smartshinobu.miraiserver.com/tokushima/todayphoto.php?iphoneid=";
    //urlstrの末尾に変数dvidを追加
	urlstr = [urlstr stringByAppendingString:dvid];
	//ここ
	//Mac book Pro のシュミレーターだとエラーが起きるので確認して下さい。
	//iPhone でもエラーがでている。

//	2014-10-29 23:25:00.521 PhotoWalk[303:38623] <__NSConcreteUUID 0x17403b000> 9557A3BB-02F7-4FC5-8B38-9DFD0683DDD2
//	2014-10-29 23:25:14.601 PhotoWalk[303:38623] -[__NSConcreteUUID length]: unrecognized selector sent to instance 0x17403b000
//	2014-10-29 23:25:14.604 PhotoWalk[303:38623] *** Terminating app due to uncaught exception 'NSInvalidArgumentException', reason: '-[__NSConcreteUUID length]: unrecognized selector sent to instance 0x17403b000'
//	*** First throw call stack:
//	(0x188599e48 0x198c8c0e4 0x1885a0f14 0x18859dcc4 0x1884a2c1c 0x1893818ac 0x100073a60 0x18cd7d0f8 0x18cd6622c 0x18cd7ca94 0x18cd7c720 0x18cd75c74 0x18cd4938c 0x18cfe81b4 0x18cd478f4 0x1885520e8 0x18855138c 0x18854f43c 0x18847d1f4 0x1916135a4 0x18cdae784 0x10007c1d0 0x1992faa08)
//	libc++abi.dylib: terminating with uncaught exception of type NSException
	
	
	
	//サーバーからのデータを配列で格納
    imgarray = [self serverdata:urlstr];
    //メソッドslidebeforeを実行
    [self slidebefore];
}

//タグというボタンを押したら呼ばれるメソッド
- (IBAction)tag:(id)sender {
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

//スライドショーが行われる前に呼ばれるメソッド
-(void)slidebefore{
    count = 0;
    //タイマーが動いているか
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    NSLog(@"%@",imgarray);
    //imgarrayの要素があるかどうか
    if ([imgarray count]>0) {
        //ラベルを隠す
        self.label.hidden = YES;
        //imageviewを表示
        self.imageview.hidden = NO;
        //タイマーを起動
        timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(slideshow) userInfo:self repeats:YES];
    }else{
        //ラベルを表示
        self.label.hidden = NO;
        //ラベルの文字を写真がありません
        self.label.text = @"写真がありません";
        //imageviewを非表示
        self.imageview.hidden = YES;
    }
}

//スライドショーのために使われるメソッド
-(void)slideshow{
    //ユーザーがアップした写真フォルダを表す文字列
    NSString *imgurl = @"http://smartshinobu.miraiserver.com/tokushima/image/";
    //変数countがimgarrayの要素数と一緒か
    if (count == [imgarray count] - 1) {
        //countの値を0にする
        count = 0;
    }else{
        //countの値をインクリメントする
        count++;
    }
    //imgarrayのcount番目文字列を格納
    NSString *imgname = [imgarray objectAtIndex:count];
    //imgnameの末尾に.jpgという文字列を追加
    imgname = [imgname stringByAppendingString:@".jpg"];
    //imgurlの末尾にimgnameを追加
    imgurl = [imgurl stringByAppendingString:imgname];
    //URLを生成
    NSURL *url = [NSURL URLWithString:imgurl];
    //URL先にあるデータを格納
    NSData *data = [NSData dataWithContentsOfURL:url];
    //dataをもとにimageviewに表示画像を設定
    self.imageview.image = [[UIImage alloc]initWithData:data];
}

//自分のサーバーのデータ(JSONのデータ)をarray型で返すメソッド
-(NSArray*)serverdata:(NSString*)url{
    //URLを生成
    NSURL *dataurl = [NSURL URLWithString:url];
    //リクエスト生成
    NSURLRequest *request = [NSURLRequest requestWithURL:dataurl cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    //レスポンスを生成
    NSHTTPURLResponse *response;
    //NSErrorの初期化
    NSError *err = nil;
    //requestによって返ってきたデータを生成
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    //データを元に文字列を生成
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //余計な文字列を削除
    str = [str stringByReplacingOccurrencesOfString:@"<!--/* Miraiserver \"NO ADD\" http://www.miraiserver.com */-->" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"<script type=\"text/javascript\" src=\"http://17787372.ranking.fc2.com/analyze.js\" charset=\"utf-8\"></script>" withString:@""];
    //strをNSData型の変数に変換
    NSData *trimdata = [str dataUsingEncoding:NSUTF8StringEncoding];
    //dataを元にJSONオブジェクトを生成
    NSArray *array = [NSJSONSerialization JSONObjectWithData:trimdata options:NSJSONReadingMutableContainers error:&err];
    //値を返す
    return array;
}

//アクションシートのボタンを押したときに呼ばれるメソッド
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //タグづけされた写真の名前の配列を取得するためのURLを表す文字列を格納する変数
    NSString *urlstr = @"http://smartshinobu.miraiserver.com/tokushima/tag.php?tag=";
    //選択したタグの名前を格納する変数
    NSString *tag = [tagarray objectAtIndex:buttonIndex];
    //エンコードする
    tag = [tag stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    //urlstrの末尾に変数tagを追加
    urlstr = [urlstr stringByAppendingString:tag];
    //サーバーからのデータを配列で格納
    imgarray = [self serverdata:urlstr];
    //メソッドslidebeforeを実行
    [self slidebefore];
    
}
@end
