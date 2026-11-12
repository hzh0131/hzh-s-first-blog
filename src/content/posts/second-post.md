---
title: 我的第二篇文章
published: 2026-11-13
description: 'Hot 100 T1 哈希算法题解'
image: ''
tags: [题解]
category: '学习'
draft: false 
lang: ''
---

## 我的第一篇正式文章 —— Hot 100 第一题哈希算法的题解
### 题目
1. 两数之和
>给定一个整数数组 nums 和一个整数目标值 target，请你在该数组中找出 和为目标值 target  的那 两个 整数，并返回它们的数组下标。你可以假设每种输入只会对应一个答案，并且你不能使用两次相同的元素。你可以按任意顺序返回答案。

```C
示例 1：
输入：nums = [2,7,11,15], target = 9
输出：[0,1]
解释：因为 nums[0] + nums[1] == 9 ，返回 [0, 1] 。

示例 2：
输入：nums = [3,2,4], target = 6
输出：[1,2]

示例 3：
输入：nums = [3,3], target = 6
输出：[0,1]
```

### 用哈希表的算法
```c
//创建哈希节点
struct hashTable{
    int key;
    int val;
    UT_hash_handle hh;
};


struct hashTable* find(int ikey);
void insert(int ikey, int ival);
int* twoSum(int* nums, int numsSize, int target, int* returnSize);

//哈希表头指针
struct hashTable *hashtable=NULL;

//寻找哈希节点
struct hashTable*find(int ikey)
{
    struct hashTable *tmp;
    HASH_FIND_INT(hashtable,&ikey,tmp);
    return tmp;
}

//插入哈希节点
void insert(int ikey,int ival)
{
    struct hashTable* it;
    it=find(ikey);
    if(it==NULL)
    {
        struct hashTable* tmp=malloc(sizeof(struct hashTable));
        if(tmp==NULL)
        {
            perror("malloc");
            exit(EXIT_FAILURE);
        }

        tmp->key=ikey;
        tmp->val=ival;
        HASH_ADD_INT(hashtable,key,tmp);
    }

    else
    {
        it->val=ival;
    }
    return ;
}


int* twoSum(int* nums, int numsSize, int target, int* returnSize)
{
    for(int i=0;i<numsSize;i++)
    {
        struct hashTable*tmp=NULL;
        tmp=find(target-nums[i]);
        
        
        if(tmp!=NULL)
        {
            int *ret=malloc(sizeof(int)*2);
            if(ret==NULL)
            {
                perror("malloc");
                exit(EXIT_FAILURE);
            }
            
            ret[0]=i;
            ret[1]=tmp->val;
            
            
            if(returnSize!=NULL)
            {
                *returnSize=2;
                return ret;
            }

            else
            return ret;
        }

        insert(nums[i],i);
    }
    if(returnSize)
    {
        *returnSize=0;
    }
    return NULL;
}
```

>解题思路
1. 定义哈希节点结构体：`key`--数据  `val`--对应下标  `hh`--基本的 uthash 内部使用的管理信息
2. 把哈希表头指针初始化为 NULL ，这样可以让后面插入哈希节点时从头开始插入。
3. `struct hashTable*find(int ikey)`。最核心是调用 `HASH_FIND_INT(hashtable,&ikey,tmp);` 函数，这里要注意传参的时候注意要传 &ikey 而不是 ikey，因为哈希表查找的时候会访问对应元素所在地址，并且还要结合数据类型来决定所要读的内存大小。
4. `void insert(int ikey,int ival)`。这里定义了一个哈希节点 it 来存调用 find 函数的结果。如果 it 不为 NULL，能找到就好办了--直接让 it->val=ival （把下标更新为此时新的val）即可。如果找不到，那就要通过 malloc 申请内存创建一个新的哈希节点并且插入进去。（常规操作，就是要注意 malloc 是否成功的判断以及调用 `HASH_ADD_INT` 时传参不要传错即可） 
