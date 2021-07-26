---
title: NOTE-数据结构
date: 2020-10-15
tags:
 - 数据结构
sidebar: auto
categories:
 -  计算机基础
---

1. 结构体定义：[https://zhuanlan.zhihu.com/p/95895868](https://zhuanlan.zhihu.com/p/95895868)
2. 普里姆算法和克鲁斯卡尔算法理解（最小生成树算法—无向图）

    Prim：维护一个数组表示当前的生成树到其它各结点最短的路径，每次并入新结点都会更新这个数组以获取当前的最短路径数组。时间复杂度为O(N^2)。

    Kruskal：实现对边的权值进行排序，每次并入生成树中的是不能形成环的最短路径。主要的时间复杂度来源于排序函数。

    ps: 普里姆算法和迪杰斯特拉算法好像哦。

3. 推排序思想：首先建立大根堆，确保这个堆中每个结点的值都比其孩子结点的大。然后在这个大根堆中每次将堆顶即最大的结点放到堆尾（和堆尾的结点交换位置），然后再交换完的堆中再进行调整找到第二大的结点，再和堆中倒数第二个结点交换位置，如此反复得到最终的有序堆（从小到大），若想得到从大到小的排序则大小比较与之相反。
4. 平衡因子：左子树高度与右子树高度的差

    平衡二叉树：[https://www.cxyxiaowu.com/1696.html](https://www.cxyxiaowu.com/1696.html)（不错）

    LR调整：先对最小不平衡树的根结点的左孩子结点进行左旋然后对根结点进行右旋。

    RL调整：先对最小不平衡树的根结点的右孩子结点进行右旋然后对根结点进行左旋。

5. 优先队列：[https://www.sohu.com/a/256022793_478315](https://www.sohu.com/a/256022793_478315)
6. 需要二叉排序树（BST）的原因：二叉排序树插入和删除的效率都不错，又可以高效的查找，其中转变为平衡二叉树（AVL）最高效。

    BST性能：

    - 查找与插入一致，最高为O(logN)。
    - 删除操作如果删除结点同时有左右孩子则为O(logn)，否则为O(1)。
7. 🌲🎄🌴🌳（与实际应用结合）：[https://www.cxyxiaowu.com/1359.html](https://www.cxyxiaowu.com/1359.html)
8. 折半插入排序每次的比较次数都是logn，while(low≤high)判断，最终找到的插入位置是high+1。
9. 唯一一个需要递归的是快排，每次确定一个元素的最终位置。
10. 只有两个空间复杂度不为O(1)的排序—快排O(logN)，归并排序O(N);

    快排空间复杂度来源于栈的空间，每次递归调用需要使用常数量空间因此空间复杂度同递归次数。

    归并排序空间复杂度来源于归并操作需要转存整个序列加上递归logN，但O(N+logN)=O(N)。

11. 平衡二叉树删除：删除数据同样需要查找数据，在删除数据后需要进行调整。一次删除最多需要需要O(logN)次旋转，因此删除数据的时间复杂度为O(logN)+O(logN)=O(2logN)。
12. 排序算法优化总结
    - **冒泡排序：**

        优化一：设标记位flag判断本躺排序是否发生了位置交换，如果未交换则说明排序完成。

        优化二：记住最后一次交换发生位置lastExchange的冒泡排序。在每趟扫描中，记住最后一次交换发生的位置lastExchange，（该位置之后的相邻记录均已有序）。下一趟排序开始时，R[1..lastExchange-1]是无序区，R[lastExchange..n]是有序区。这样，一趟排序可能使当前无序区扩充多个记录，因此记住最后一次交换发生的位置lastExchange，从而减少排序的趟数。

    - **直接插入排序：**希尔排序是直接插入排序的优化，直接插入如果最后一个元素最小需要向前移动很多次效率不高，因此使用希尔排序缩小增量。
    - **选择排序：**在每一次查找最小值的时候，也可以找到一个最大值，然后将两者分别放在它们应该出现的位置，这样遍历的次数就比较少了。代码中，第一次交换结束后，如果left那个位置原本放置的就是最大数，交换之后，需要将最大数的下标还原。 需要注意的是，每次记住的最小值或者最大值的下标，这样方便进行交换。
    - **快速排序：**

        优化一：选比较枢纽元时用三点取中或随机选取法避免分区不平衡的情况。

        优化二：当数据规模较小的时候，开栈递归、选基准（最费时）、分数组中涉及常量、系数及低阶项都有影响时间复杂度的可能，因此不适合用快排。递归到一定深度可以直接插入排序或堆排序，因为直接插入在接近有序时为O(N)，堆排序最坏是O(nlogn)。

        递归栈空间有限，防止深度太大栈溢出

        优化三：三分区。分成小于枢纽等于枢纽和大于枢纽，避免了存在很多重复元素的时候对这些元素的重复处理。

13. TopK问题解法：
    - 快排优化：调用快排的partition，找到基准所在下标为j，若j>k则下一次递归在j左面找k；若j=k左面为TopK；若j<k则在右面找k-j。时间复杂度O(N)。

    ```cpp
    class Solution {
    private:
        vector<int> res;
    public:
        vector<int> getLeastNumbers(vector<int>& arr, int k) {
            if(arr.empty() || k == 0) {return {};}
            return quickSelection(arr, 0, arr.size() - 1, k - 1); // 注意第 k 个数对应的下标是 k - 1
        }
        vector<int> quickSelection(vector<int>& arr, int left, int right, int index) {
            // partition函数将一个区间内所有小于下标为 j 的数放在 j 左边，大于下标为 j 的数放在 j 右边
            int j = partition(arr, left, right); 
            
            if(j == index) { // 若 j 刚好等于 k - 1，将 arr[0] 至 arr[j] 输入 res
                for(int i = 0; i < j + 1; ++i) {res.push_back(arr[i]);}
                return res;
            }
            // 若 j 小于 k - 1，将区间变成 [j + 1, right]；反之，区间变成 [left, j - 1]
            return j < index ? quickSelection(arr, j + 1, right, index) : quickSelection(arr, left, j - 1, index);
        }
        int partition(vector<int>& arr, int left, int right) {
            int value = arr[left];
            int i = left, j = right + 1;

            while(true) {
                while(++ i <= right && arr[i] < value); // 找到从左往右第一个大于等于 value 的下标
                while(-- j >= left && arr[j] > value); // 找到从右往左第一个小于等于 value 的下标
                if(i >= j) {break;} // 如果找不到，说明已经排好序了，break
                swap(arr[i], arr[j]); // 如果找到了，交换二者
            }
            swap(arr[left], arr[j]); // arr[j]是小于 value 的，这一步使得所有小于下标为 j 的数都在 j 左边

            return j;
        }
        void swap(int& a, int& b) { 
            int temp = a;
            a = b;
            b = temp;
        }
    };
    ```

    - 堆排序（优先队列）：时间复杂度O(NlogK)。