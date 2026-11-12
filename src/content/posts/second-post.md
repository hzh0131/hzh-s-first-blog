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
    hashtable=NULL;
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
5. `int* twoSum(int* nums, int numsSize, int target, int* returnSize)`。最重要的一个函数，核心思路就是通过 `find` 函数来查找每一个元素在现有的哈希表中是否存在“补值” （即 `target-nums[i]`）。如果不存在补值，那就把当前节点插入哈希表中，并且在检验 `returnSize` 存在之后把其指针解引用并赋值为0 。如果能找到，那就通过 malloc 新申请一块内存用来存放满足条件的两个元素的下标。再检验并赋值 `returnSize` 即可。（这里还是要注意 malloc 要检验是否成功）

>踩过的坑
### Two Sum 哈希表算法：疑问与知识点总结

| 序号 | 容易混淆或理解错误的地方 | 正确解释 |
|---|---|---|
| 1 | 为什么 `HASH_FIND_INT(hashtable, &ikey, tmp)` 要传入 `ikey` 的地址，而不是直接传入数值？ | 因为 uthash 的查找接口要求传入待查找数据的内存地址。它会结合数据类型对应的长度（这里是 `sizeof(int)`），从该地址读取数据并进行比较。真正查找的是地址中存储的整数值，而不是地址本身。 |
| 2 | 传入地址是不是因为程序不确定参数的大小？ | 不完全是。主要是因为 uthash 采用通用接口设计，需要通过地址获取数据，再结合数据长度读取相应内容。不同类型的数据可以使用不同的长度进行处理。 |
| 3 | `find()` 中为什么要定义 `struct hashTable* tmp`？ | `tmp` 是一个指针变量，用来接收 `HASH_FIND_INT()` 的查找结果。查找成功时，它指向哈希表中已经存在的节点；查找失败时，它为 `NULL`。它本身并没有申请新的节点内存。 |
| 4 | 为什么 `insert()` 中又要重新定义一个 `tmp`？ | `find()` 中的 `tmp` 和 `insert()` 中的 `tmp` 属于不同的函数作用域，是两个不同的局部变量。前者接收查找结果，后者在需要插入新节点时指向通过 `malloc()` 申请的内存。 |
| 5 | 为什么不能直接把 `it` 插入哈希表，而要重新申请一块内存？ | `it` 是 `find()` 返回的查找结果。如果没有找到节点，`it == NULL`，不能直接插入哈希表。因此需要通过 `malloc()` 申请新的节点，设置其成员，再使用 `HASH_ADD_INT()` 插入。 |
| 6 | `HASH_FIND_INT()` 是否会创建新的哈希节点？ | 不会。它只负责查找已有节点，并将查找结果赋值给输出指针。真正创建节点需要使用 `malloc()`，真正插入节点需要使用 `HASH_ADD_INT()`。 |
| 7 | 为什么哈希表头指针要初始化为 `NULL`？ | `hashtable` 是哈希表的入口指针。初始化为 `NULL` 表示当前哈希表为空，让 uthash 能够正确识别尚未建立节点的哈希表。 |
| 8 | 为什么在 `twoSum()` 中还需要重新初始化哈希表？ | 因为 `hashtable` 是全局变量。如果函数被多次调用，上一次调用留下的节点可能影响下一次查找。因此每次调用都需要从空哈希表开始。不过，不能直接将旧指针置为 `NULL`，否则会丢失旧节点的地址，造成内存泄漏。应该先释放旧节点，再初始化。 |
| 9 | 哈希表中的 `key` 和 `val` 分别表示什么？ | 在 Two Sum 中，`key` 存储原数组中的数字 `nums[i]`，`val` 存储这个数字在原数组中的下标 `i`。 |
| 10 | `val` 是不是哈希表中节点的下标？ | 不是。`val` 记录的是原始 `nums` 数组中的下标，而不是哈希表内部的位置。哈希表只是利用 `key` 快速查找，并通过 `val` 找回原数组中的位置。 |
| 11 | 为什么找到相同的 `key` 后要更新原节点的 `val`？ | 因为 uthash 不允许在同一个哈希表中存在多个相同键的节点。遇到重复的 `key` 时，可以更新原节点的 `val`，让它记录最新出现的下标。对于当前 Two Sum 算法，保留最早或最新的下标都可以得到一组有效答案。 |
| 12 | 为什么查找时使用 `target - nums[i]`，插入时却使用 `nums[i]`？ | 两个操作的目的不同。查找时，需要寻找当前数字的补数，因此使用 `find(target - nums[i])`。插入时，需要保存当前已经遍历过的数字及其下标，因此使用 `insert(nums[i], i)`。 |
| 13 | 为什么要先查找，再插入？ | 因为题目要求两个数字必须来自不同的数组下标。先查找可以保证哈希表中只有当前元素之前遍历过的数字，避免将当前元素与自己配对。 |
| 14 | 如果两个数字相同，例如 `nums = {3, 3}`，`target = 6`，怎么办？ | 不需要特殊处理。第一次遇到 3 时，哈希表中还没有 3，于是插入 `(3, 0)`。第二次遇到 3 时，查找成功，得到下标 0，再与当前下标 1 组成答案 `[0, 1]`。 |
| 15 | 为什么返回结果时可以写 `ret[0] = i; ret[1] = tmp->val;`？ | `i` 是当前数字在原数组中的下标，`tmp->val` 是之前找到的补数在原数组中的下标。两者顺序可以交换，因为题目不要求下标按照从小到大的顺序排列。 |
| 16 | 为什么 `returnSize = 0` 是错误的？ | `returnSize` 是指针，直接赋值只会修改指针本身，而不是调用者传入的整数。应该使用 `*returnSize = 0`，通过解引用修改调用者的变量。 |
| 17 | 为什么要判断 `returnSize != NULL`？ | 因为函数参数是一个指针，调用者可能传入空指针。只有指针不为 `NULL` 时，才能安全地通过 `*returnSize` 修改其指向的变量。 |
| 18 | 为什么哈希表节点需要释放内存？ | 每次使用 `malloc()` 创建节点都会占用堆内存。使用完毕后，需要通过 `HASH_DEL()` 将节点从哈希表中删除，再使用 `free()` 释放节点内存，避免内存泄漏。 |
| 19 | 为什么找到答案后要先保存 `tmp->val`，再释放哈希表？ | 因为 `tmp` 指向哈希表中的节点。如果先释放节点，`tmp` 就会变成悬空指针，再访问 `tmp->val` 会产生未定义行为。因此必须先将需要的数据保存到结果数组，再释放哈希表。 |
| 20 | 为什么在线评测中可能出现 `[0,0]`，而预期结果是 `[0,1]`？ | 一种可能是全局哈希表没有在每次调用前清空，导致上一次测试的数据残留。本次查找可能错误地找到旧节点，从而返回 `[0,0]`。应在每次调用前释放旧哈希表，再重新初始化。 |
