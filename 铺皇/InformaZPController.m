//
//  InformaZPController.m
//  铺皇
//
//  Created by 铺皇网 on 2017/6/26.
//  Copyright © 2017年 中国铺皇. All rights reserved.
//

#import "InformaZPController.h"

@interface InformaZPController ()<UITableViewDelegate,UITableViewDataSource>{
    int  PHpage;
}

@property   (nonatomic, strong) UITableView     *   InformaZPtableView;
@property   (nonatomic, strong) UILabel         *   BGlab;          //无网络提示语
@property   (nonatomic, strong) NSMutableArray  *   PHArr; //存储数据


@end

@implementation InformaZPController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor =[UIColor whiteColor];
    _PHArr             = [[NSMutableArray alloc]init];
    self.title = @"我的招聘发布";
    [self creattableview];
    [self refresh];
   
    
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
   [self.navigationController setNavigationBarHidden:NO animated:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
  
}

#pragma mark 网络检测
-(void)reachability{
    
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        NSLog(@"status=%ld",status);
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            
            [self loaddataZP         ];
        }
        else{
            NSLog(@"网络繁忙");
        }
    }];
}

#pragma mark - 刷新数据
- (void)refresh{
#pragma  -mark下拉刷新获取网络数据
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reachability)];
    // Set title
    [header setTitle:@"铺小皇来开场了" forState:MJRefreshStateIdle];
    [header setTitle:@"铺小皇要回家了" forState:MJRefreshStatePulling];
    [header setTitle:@"铺小皇来更新了" forState:MJRefreshStateRefreshing];
    // Set font
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // Set textColor
    header.stateLabel.textColor = kTCColor(161, 161, 161);
    header.lastUpdatedTimeLabel.textColor = kTCColor(161, 161, 161);
    self.InformaZPtableView.mj_header = header;
    [self.InformaZPtableView.mj_header beginRefreshing];
#pragma  -mark上拉加载获取网络数据
    self.InformaZPtableView.mj_footer=[MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        NSLog(@"上一个第%d页",PHpage       );
        PHpage++;
        [self loaddatamoreZP];
    }];
}

#pragma -mark 上啦加载新数据
-(void)loaddatamoreZP{
    
    [self.BGlab setHighlighted:YES];
    NSLog(@"即将下来刷新数据数组当前有%ld个数据",_PHArr.count);
    [YJLHUD showMyselfBackgroundColor:nil ForegroundColor:nil BackgroundLayerColor:nil message:@"加载中..."];
    AFHTTPSessionManager *manager       = [AFHTTPSessionManager manager];
    manager.responseSerializer          = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.0;
    NSDictionary *params = @{
                             @"publisher":[[YJLUserDefaults shareObjet]getObjectformKey:YJLuser],
                             @"page":[NSString stringWithFormat:@"%d",PHpage]
                             };
    [manager POST: InformaZRpath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"入境:%@",InformaZRpath);
        
      [YJLHUD dismissWithDelay:0.2];
        //        NSLog(@"请求成功咧");
        //        NSLog(@"数据:%@", responseObject[@"data"]);
        if ([[responseObject[@"code"] stringValue] isEqualToString:@"200"]){
            NSLog(@"可以拿到数据的");
            
            for (NSDictionary *dic in responseObject[@"data"]){
                
                InformaZPmodel *model = [[InformaZPmodel alloc]init];
                model.InfoZP_job        = dic[@"category"   ];
                model.InfoZP_time       = dic[@"time"       ];
                model.InfoZP_title      = dic[@"name"       ];
                model.InfoZP_area       = dic[@"districter" ];
                model.InfoZP_suffer     = dic[@"experience" ];
                model.InfoZP_educa      = dic[@"edu"        ];
                model.InfoZP_salary     = dic[@"money"      ];
                model.InfoZP_subid      = dic[@"id"         ];
                model.InfoZP_shenhe     = dic[@"shenhe"         ];
                [model setValuesForKeysWithDictionary:dic   ];
                [_PHArr addObject:model];
            }
            
            //            NSLog(@" 加载后现在总请求到数据有%ld个",_PHArr.count);
            [self.BGlab setHidden:YES];
        }
        
        else{
            //code 309
            NSLog(@"不可以拿到数据的");
            [YJLHUD showErrorWithmessage:@"没有更多数据"];
            [YJLHUD dismissWithDelay:2];
            PHpage --;
            [self.InformaZPtableView.mj_footer endRefreshingWithNoMoreData];
        }
        
        [self.InformaZPtableView reloadData];
        [self.InformaZPtableView.mj_footer endRefreshing];//停止刷新
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        NSLog(@"error=====%@",error);
        [self.InformaZPtableView.mj_header endRefreshing];//停止刷新
        [YJLHUD showErrorWithmessage:@"网络数据连接失败"];
        [YJLHUD dismissWithDelay:2];
    }];
}

#pragma  -mark下拉刷新
-(void)loaddataZP{

    [self.InformaZPtableView.mj_footer resetNoMoreData];
    PHpage = 0;
    [self.BGlab setHighlighted:YES];
    NSLog(@"即将下来刷新数据数组当前有%ld个数据",_PHArr.count);
    [YJLHUD showMyselfBackgroundColor:nil ForegroundColor:nil BackgroundLayerColor:nil message:@"加载中..."];
    AFHTTPSessionManager *manager       = [AFHTTPSessionManager manager];
    manager.responseSerializer          = [AFJSONResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.0;
            NSDictionary *params = @{
                         @"publisher":[[YJLUserDefaults shareObjet]getObjectformKey:YJLuser]
                         };

        [manager POST:InformaZPpath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
            NSLog(@"Lsp～招聘发布～ 🐷,赶紧加载数据啦4444444");
            [_PHArr removeAllObjects];
            [YJLHUD showSuccessWithmessage:@"加载成功"];
            [YJLHUD dismissWithDelay:1];
            NSLog(@"请求成功咧");
            NSLog(@"数据:%@",responseObject[@"data"]);
            
    if ([[responseObject[@"code"] stringValue] isEqualToString:@"200"]){
        NSLog(@"可以拿到数据的");

        for (NSDictionary *dic in responseObject[@"data"]){
            InformaZPmodel *model = [[InformaZPmodel alloc]init];
            model.InfoZP_job        = dic[@"category"   ];
            model.InfoZP_time       = dic[@"time"       ];
            model.InfoZP_title      = dic[@"name"       ];
            model.InfoZP_area       = dic[@"districter" ];
            model.InfoZP_suffer     = dic[@"experience" ];
            model.InfoZP_educa      = dic[@"edu"        ];
            model.InfoZP_salary     = dic[@"money"      ];
            model.InfoZP_subid      = dic[@"id"         ];
            model.InfoZP_shenhe     = dic[@"shenhe"         ];
            [model setValuesForKeysWithDictionary:dic   ];
            [_PHArr addObject:model];
        }
        
        NSLog(@" 加载后现在总请求到数据有%ld个",_PHArr.count);
        [self.BGlab setHidden:YES];
        
    }
    else{
        
        //code 305
            NSLog(@"不可以拿到数据的");
      
            [self.BGlab setHidden:NO];
            self.BGlab.text = @"没有更多数据哦～";
            [YJLHUD showErrorWithmessage:@"没有更多数据"];
            [YJLHUD dismissWithDelay:1];
            [self.InformaZPtableView.mj_footer endRefreshingWithNoMoreData];
        
    }
        [self.InformaZPtableView reloadData];
        [self.InformaZPtableView.mj_header endRefreshing];//停止刷新
 } failure:^(NSURLSessionDataTask *task, NSError *error) {
             NSLog(@"error=====%@",error);
             [self.BGlab setHighlighted:NO];
             [self.InformaZPtableView.mj_header endRefreshing];//停止刷新
            [YJLHUD showErrorWithmessage:@"网络数据连接失败"];
            [YJLHUD dismissWithDelay:1];
    
    }];
}

#pragma - mark 创建tabliview  & 无网络背景
- (void)creattableview{
    
    //    创建tableview列表
    self.InformaZPtableView                 = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.InformaZPtableView.delegate        = self;
    self.InformaZPtableView.dataSource      = self;
    self.InformaZPtableView.backgroundColor = [UIColor clearColor];
    self.InformaZPtableView.tableFooterView = [UIView new];
    [self.view addSubview:self.InformaZPtableView];
    
    //    无数据的提示
    self.BGlab                   = [[UILabel alloc]init];
    [self.InformaZPtableView addSubview:self.BGlab];
    self.BGlab.font             = [UIFont systemFontOfSize:12.0f];
    self.BGlab.textColor        = kTCColor(161, 161, 161);
    self.BGlab.backgroundColor  = [UIColor clearColor];
    self.BGlab.textAlignment    = NSTextAlignmentCenter;
    [self.BGlab setHidden:YES];                              //隐藏提示
    [self.BGlab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.InformaZPtableView);
        make.size.mas_equalTo(CGSizeMake(200, 20));
    }];
}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    self.InformaZPtableView.frame = self.view.bounds;
}

#pragma mark - Tableviewdatasource代理
//几个段落Section
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

//一个段落几个row
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _PHArr.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //        自定义
    static NSString *cellID = @"cellname";
    informaZPCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil){
        
        cell = [[[NSBundle mainBundle]loadNibNamed:@"informaZPCell" owner:self options:nil]lastObject];
    }
    
    InformaZPmodel*model =[_PHArr objectAtIndex:indexPath.row];
    cell.InformaZPjob.text  = model.InfoZP_job;
    cell.InformaZPtitle.text = model.InfoZP_title;
    cell.InformaZPtime.text = [NSString stringWithFormat:@"发布时间:%@",  model.InfoZP_time];
    cell.InformaZParea.text = [NSString stringWithFormat:@"%@",    model.InfoZP_area];
    cell.InformaZPsuffer.text = [NSString stringWithFormat:@"%@",  model.InfoZP_suffer];
    cell.InformaZPeduca.text = [NSString stringWithFormat:@"%@",model.InfoZP_educa];
    if ([model.InfoZP_salary isEqualToString:@"面议"]) {
         cell.InformaZPsalary.text =[NSString stringWithFormat:@"%@",model.InfoZP_salary];
    }else{
         cell.InformaZPsalary.text =[NSString stringWithFormat:@"%@/月",model.InfoZP_salary];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
    switch ([model.InfoZP_shenhe integerValue]) {
        case 0:{
            cell.InformaZPshenhe.text = @"审核中";
            cell.InformaZPshenhe.textColor = kTCColor(255, 0, 0);
        }
            break;
        case 1:{
            cell.InformaZPshenhe.text = @"服务中";
            cell.InformaZPshenhe.textColor = kTCColor(77, 166, 214);
        }
            break;
        
        case 2:{
            cell.InformaZPshenhe.text = @"审核失败";
            cell.InformaZPshenhe.textColor = kTCColor(255, 0, 0);
        }
            break;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 85;
}

#pragma mark - 点击事件
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"第%ld大段==第%ld行",indexPath.section,indexPath.row);
    InformaZPmodel *model = [_PHArr objectAtIndex:indexPath.row];
    NSLog(@"店铺🆔:%@",model.InfoZP_subid);
    switch ([model.InfoZP_shenhe integerValue]) {
        case 0:{
         #pragma mark           "审核中";
            SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                                        cancelTitle:@"取消"
                                                                   destructiveTitle:nil
                                                                        otherTitles:@[@"查看详情",@"删除信息"]
                                                                        otherImages:nil
                                                                  selectActionBlock:^(SRActionSheet *actionSheet, NSInteger index) {
                                                                      NSLog(@"%zd", index);
                                                                      switch (index) {
                                                                          case 0:{
                                                                              
                                                                              
                                                                              ResumeXQController *ctl =[[ResumeXQController alloc]init];
                                                                              InformaZPmodel *model =[_PHArr objectAtIndex:indexPath.row];

                                                                              ctl.shopsubid = model.InfoZP_subid;
                                                                              self.hidesBottomBarWhenPushed = YES;//如果在push跳转时需要隐藏tabBar
                                                                              [self.navigationController pushViewController:ctl animated:YES];
                                                                              self.hidesBottomBarWhenPushed = YES;//1.并在push后设置self.hidesBottomBarWhenPushed=YES;2.这样back回来的时候，tabBar不会会恢复正常显示。
                                                                          }
                                                                              break;
                                                                              
                                                                          case 1:{
                                                                              
                                                                              NSLog(@"删除信息");
                                                                             [YJLHUD showMyselfBackgroundColor:nil ForegroundColor:nil BackgroundLayerColor:nil message:@"删除信息中..."];
                                                                              
                                                                              AFHTTPSessionManager *manager       = [AFHTTPSessionManager manager];
                                                                              manager.responseSerializer          = [AFJSONResponseSerializer serializer];
                                                                              manager.requestSerializer.timeoutInterval = 10.0;
                                                                    
                                                                              
                                                                              NSDictionary *params = @{
                                                                                                       @"shopid":model.InfoZP_subid
                                                                                                       };
                                                                              NSLog(@"店铺🆔:%@",model.InfoZP_subid);
                                                                              [manager GET: InformaZPDEpath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                                  
                                                                                  NSLog(@"数据:%@", responseObject);
                                                                                  
                                                                                  if ([[responseObject[@"code"] stringValue] isEqualToString:@"200"]){
                                                                                      NSLog(@"成功删除");
                                                                                     
                                                                                      [YJLHUD showSuccessWithmessage:@"删除成功"];
                                                                                      [YJLHUD dismissWithDelay:2];
                                                                                      [_PHArr removeObjectAtIndex:indexPath.row];
                                                                                      
                                                                             
                                                                                      [self.InformaZPtableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                                                                                      
                                                                                  }
                                                                                  else{
                                                                                      
                                                                                      //code 305
                                                                                      NSLog(@"失败删除");
                                                                                     
                                                                                      [YJLHUD showErrorWithmessage:@"删除失败"];
                                                                                      [YJLHUD dismissWithDelay:2];
                                                                                  }
                                                                                  
                                                                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                                  
                                                                                  NSLog(@"error=====%@",error);
                                                                                 
                                                                                  [YJLHUD showErrorWithmessage:@"网络数据连接出现问题了,请检查一下"];
                                                                                  [YJLHUD dismissWithDelay:2];
                                                                                  
                                                                              }];
                                                                          }
                                                                              break;
                                                                          
                                                                      }
                                                                  }];
            [actionSheet show];
        }
            break;
            
        case 1:{
    #pragma mark   "服务中";
            
            SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                                        cancelTitle:@"取消"
                                                                   destructiveTitle:nil
                                                                        otherTitles:@[@"查看详情"]
                                                                        otherImages:nil
                                                                  selectActionBlock:^(SRActionSheet *actionSheet, NSInteger index) {
                                                                      NSLog(@"%zd", index);
                                                                      switch (index) {
                                                                          case 0:{
                                                                              
                                                                              
                                                                              ResumeXQController *ctl =[[ResumeXQController alloc]init];
                                                                              InformaZPmodel *model =[_PHArr objectAtIndex:indexPath.row];
                                                                              ctl.shopsubid = model.InfoZP_subid;
                                                                              self.hidesBottomBarWhenPushed = YES;//如果在push跳转时需要隐藏tabBar
                                                                              [self.navigationController pushViewController:ctl animated:YES];
                                                                              self.hidesBottomBarWhenPushed = YES;//1.并在push后设置self.hidesBottomBarWhenPushed=YES;2.这样back回来的时候，tabBar不会会恢复正常显示。
                                                                          }
                                                                              break;
                                                                      }
                                                                  }];
            [actionSheet show];
        }
            break;

        case 2:{
 #pragma mark "审核失败";
            SRActionSheet *actionSheet = [SRActionSheet sr_actionSheetViewWithTitle:nil
                                                                        cancelTitle:@"取消"
                                                                   destructiveTitle:nil
                                                                        otherTitles:@[@"查看详情",@"删除信息"]
                                                                        otherImages:nil
                                                                  selectActionBlock:^(SRActionSheet *actionSheet, NSInteger index) {
                                                                      NSLog(@"%zd", index);
                                                                      switch (index) {
                                                                          case 0:{
                                                                              
                                                                              ResumeXQController *ctl =[[ResumeXQController alloc]init];
                                                                              InformaZPmodel *model =[_PHArr objectAtIndex:indexPath.row];
                                                                              ctl.shopsubid = model.InfoZP_subid;
                                                                              self.hidesBottomBarWhenPushed = YES;//如果在push跳转时需要隐藏tabBar
                                                                              [self.navigationController pushViewController:ctl animated:YES];
                                                                              self.hidesBottomBarWhenPushed = YES;//1.并在push后设置self.hidesBottomBarWhenPushed=YES;2.这样back回来的时候，tabBar不会会恢复正常显示。
                                                                          }
                                                                              break;
                                                                              
                                                                          case 1:{
                                                                              
                                                                              NSLog(@"删除信息");
                                                                              [YJLHUD showMyselfBackgroundColor:nil ForegroundColor:nil BackgroundLayerColor:nil message:@"删除信息中..."];
                                                                              
                                                                              AFHTTPSessionManager *manager       = [AFHTTPSessionManager manager];
                                                                              manager.responseSerializer          = [AFJSONResponseSerializer serializer];
                                                                              manager.requestSerializer.timeoutInterval = 10.0;
                                                                              
                                                                              
                                                                              NSDictionary *params = @{
                                                                                                       @"shopid":model.InfoZP_subid
                                                                                                       };
                                                                              NSLog(@"店铺🆔:%@",model.InfoZP_subid);
                                                                              [manager GET: InformaZPDEpath parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                                                                                  
                                                                                  NSLog(@"数据:%@", responseObject);
                                                                                  
                                                                                  if ([[responseObject[@"code"] stringValue] isEqualToString:@"200"]){
                                                                                      NSLog(@"成功删除");
                                                                                      
                                                                                      [YJLHUD showSuccessWithmessage:@"删除成功"];
                                                                                      [YJLHUD dismissWithDelay:2];
                                                                                      [_PHArr removeObjectAtIndex:indexPath.row];
                                                                                      
                                                                                      
                                                                                      [self.InformaZPtableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                                                                                      
                                                                                  }
                                                                                  else{
                                                                                      
                                                                                      //code 305
                                                                                      NSLog(@"失败删除");
                                                                                      
                                                                                      [YJLHUD showErrorWithmessage:@"删除失败"];
                                                                                      [YJLHUD dismissWithDelay:2];
                                                                                  }
                                                                                  
                                                                              } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                                                  
                                                                                  NSLog(@"error=====%@",error);
                                                                                  
                                                                                  [YJLHUD showErrorWithmessage:@"网络数据连接出现问题了,请检查一下"];
                                                                                  [YJLHUD dismissWithDelay:2];
                                                                                  
                                                                              }];
                                                                          }
                                                                              break;
                                                                      }
                                                                  }];
            [actionSheet show];
        }
            break;
    }
}

@end
