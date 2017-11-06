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
#import "NJKWebViewProgressView.h"
#import "NJKWebViewProgress.h"

@interface NJKWebViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate,NJKWebViewProgressDelegate>

@property(nonatomic,strong)UIWebView * webView;
@property (nonatomic,strong) UIProgressView *progress;
//直接关闭按钮
@property(nonatomic,strong)UIButton * closeButton;

@end

@implementation NJKWebViewController
{
    NJKWebViewProgressView *_NJProgressView;
    NJKWebViewProgress     *_NJProgressProxy;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:_NJProgressView];
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:94/255.0 green:214/255.0 blue:253/255.0 alpha:1.0];
    
    [self createBackButton];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_NJProgressView removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    [self createView];
}

#pragma mark 创建UI
-(void)createView
{
    [self.view addSubview:self.webView];
    [self loadWebViewContent];
}

#pragma mark 加载数据源
-(void)loadWebViewContent
{
    [self configurationWebNavigateProgress];
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
    }
    return _webView;
}

#pragma mark 加载进度条
- (UIProgressView *)progress
{
    if (_progress == nil)
    {
        _progress = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 2)];
        _progress.tintColor = [UIColor blueColor];
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
    
    if(self.ClickBackBtnDirectBlock)
    {
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

#pragma mark NJKWebViewProgressDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    [_NJProgressView setProgress:progress animated:YES];
}

#pragma mark 加载进度条
- (void)configurationWebNavigateProgress{
    
    if (!_NJProgressProxy) {
        _NJProgressProxy = [[NJKWebViewProgress alloc]init];
    }else{
        //不再创建新的对象
    }
    _webView.delegate = _NJProgressProxy;
    _NJProgressProxy.webViewProxyDelegate = self;
    _NJProgressProxy.progressDelegate = self;
    
    CGFloat progressBarH = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarH, navigationBarBounds.size.width, progressBarH);
    _NJProgressView = [[NJKWebViewProgressView alloc]initWithFrame:barFrame];
    _NJProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
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
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (theTitle.length > 10) {
        theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
    }
    self.navigationItem.title = theTitle;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
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
