//
//  NJKWebViewController.m
//  JiudouyuApp
//
//  Created by 薛晶锦 on 2017/11/6.
//  Copyright © 2017年 张一力. All rights reserved.
//

//status高度 iphoneX=44 other=20
#define STATUS_height  [[UIApplication sharedApplication] statusBarFrame].size.height
//navigationHeight 44
#define NAVIGATION_height  self.navigationController.navigationBar.frame.size.height

#import "NJKWebViewController.h"
#import "ODRefreshControl.h"

@interface NJKWebViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIProgressView *progress;
//直接关闭按钮
@property(nonatomic,strong)UIButton * closeButton;
@property(nonatomic,strong)ODRefreshControl * refreshControl;

@end

@implementation NJKWebViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:94/255.0 green:214/255.0 blue:253/255.0 alpha:1.0];
    
    [self createBackButton];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self createView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnToNextLevel:) name:@"comeFromH5View" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(turnToNextLevel:) name:@"reloadH5" object:nil];
}

#pragma mark 创建UI
-(void)createView
{
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progress];
    [self loadWebViewContent];
}

#pragma mark 加载数据源
-(void)loadWebViewContent
{
    if(self.webLoadType == LOADHtml)
    {
        [_webView loadHTMLString:_loadTypeHtmlString baseURL:nil];
    }else
    {
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }
}

#pragma mark 创建UIWebView
-(UIWebView *)webView
{
    if(!_webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - STATUS_height - NAVIGATION_height)];
        _webView.delegate = self;
        self.refreshControl = [[ODRefreshControl alloc] initInScrollView:_webView.scrollView];
        [self.refreshControl addTarget:self action:@selector(updateWebView) forControlEvents:UIControlEventValueChanged];
    }
    return _webView;
}

-(void)updateWebView
{
    [self.webView reload];
}

#pragma mark 加载进度条
- (UIProgressView *)progress
{
    if (_progress == nil)
    {
        _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
        _progress.tintColor = [UIColor colorWithRed:253.f / 255.f green:181.f / 255.f blue:59.f / 255.f alpha:1.0];
        _progress.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_progress];
    }
    return _progress;
}

#pragma mark 创建返回键逻辑
-(void)createBackButton
{
    //返回箭头
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 40)];
    [backButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    //关闭按钮
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(60, 10, 50, 20)];
    [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _closeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_closeButton addTarget:self action:@selector(backToMethod) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.titleEdgeInsets = UIEdgeInsetsMake(0, -30, 0, 0);
    _closeButton.clipsToBounds   = NO;
    _closeButton.hidden = YES;
    UIBarButtonItem * closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_closeButton];
    
    self.navigationItem.leftBarButtonItems = @[backButtonItem,closeButtonItem];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
}
//返回按钮action
-(void)backAction{
    if([self.webView canGoBack]){
        [self.webView goBack];
        _closeButton.hidden = NO;
    }else{
        [self backToMethod];
        _closeButton.hidden = YES;
    }
}
//返回跳转封装
-(void)backToMethod{
    
    if(self.ClickBackBtnDirectBlock){
        self.ClickBackBtnDirectBlock();
        return;
    }
    
    !self.ClickBackBtnBlock?:self.ClickBackBtnBlock();
    
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma makr UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString * urlStr = [request.URL absoluteString];
    NSLog(@"%@",urlStr);
    NSArray *urlComps = [urlStr componentsSeparatedByString:@":"];
    
    if([urlComps count] && [[urlComps objectAtIndex:0] isEqualToString:@"objc"]){
        
        NSString * go_back = [urlComps objectAtIndex:1];
        NSLog(@"js交互%@",go_back);
        !self.jumpLogic?:self.jumpLogic(go_back);
//        [self captureH5Msg:go_back];
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.progress.hidden = NO;
    self.progress.progress = 0;
    [self.progress setProgress:0.8 animated:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.progress setProgress:1.0 animated:YES];
    self.progress.progress = 0;
    self.progress.hidden = YES;
    [self.refreshControl endRefreshing];
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (theTitle.length > 10) {
        theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
    }
    self.navigationItem.title = theTitle;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.progress setProgress:1.0 animated:YES];
    self.progress.progress = 0;
    self.progress.hidden = YES;
    [self.refreshControl endRefreshing];
}

- (void)turnToNextLevel:(NSNotification *)notic{
    [self.webView reload];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

@end
