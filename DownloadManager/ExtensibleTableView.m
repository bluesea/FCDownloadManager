//
//  ExtensibleTableView.m
//  Tangyou
//
//  Created by Ping on 14-1-6.
//
//

#import "ExtensibleTableView.h"

@implementation ExtensibleTableView
@synthesize delegate_extend;
@synthesize currentIndexPath;

- (id)init
{
    self.currentIndexPath =nil;
    return [super init];
}

//重写设置代理的方法，使为UITableView设置代理时，将子类的delegate_extend同样设置
- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    self.delegate_extend = delegate;
    [super setDelegate:delegate];
}

//将indexPath对应的row展开
- (void)extendCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated goToTop:(BOOL)goToTop
{
    //被取消选中的行的索引
    NSIndexPath *unselectedIndex = [NSIndexPath indexPathForRow:[self.currentIndexPath row]inSection:[self.currentIndexPath section]];
    //要刷新的index的集合
    NSMutableArray *array = [[NSMutableArray alloc]init];
    //若当前index不为空
    if(self.currentIndexPath)
    {
        //被取消选中的行的索引
        [array addObject:unselectedIndex];
    }
    //若当前选中的行和入参的选中行不相同，说明用户点击的不是已经展开的cell
    if(![self isEqualToSelectedIndexPath:indexPath])
    {
        //被选中的行的索引
        [array addObject:indexPath];
    }
    //将当前被选中的索引重新赋值
    self.currentIndexPath = indexPath;
    
    if(animated)
    {
        [self reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        [self reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
    }
    if(goToTop)
    {
        //tableview滚动到新选中的行的高度
        [self scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    [array release];
}

//将展开的cell收起
- (void)shrinkCellWithAnimated:(BOOL)animated
{
    //要刷新的index的集合
    NSMutableArray *array = [[NSMutableArray alloc]init];
    if(self.currentIndexPath)
    {
        //当前展开的cell的索引
        [array addObject:self.currentIndexPath];
        //将当前展开的cell的索引设为空
        self.currentIndexPath =nil;
        [self reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
    }
    [array release];
}

//查看传来的索引和当前被选中索引是否相同
- (BOOL)isEqualToSelectedIndexPath:(NSIndexPath *)indexPath
{
    if(self.currentIndexPath)
    {
        return ([self.currentIndexPath row] == [indexPath row]) && ([self.currentIndexPath section] == [indexPath section]);
    }
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.currentIndexPath row] == [indexPath row])
    {
        return [self.delegate_extend tableView:self extendedHeightForRowAtIndexPath:indexPath];
    }
    return [super rowHeight];
}

@end
