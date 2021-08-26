---
title: Scala 入门学习（六）： Set、Map、其它集合
date: 2021-08-15
tags:
 - Scala
sidebar: auto
categories:
 -  大数据
---

> 本系列文章会着重介绍Scala与Java的不同点，较适合学习过Java的人阅读。
> 
> 本篇文章会继续介绍Scala的其它集合类型。

## Scala —— 其它集合

### Set

Set 是一个数据无序的集合，集合内元素**不可重复**，同样提供可变和不可变两个版本，默认是不可变的 Set。

1）不可变 Set

创建集合：Set 是特质无法直接 new，创建方法和之前在 ArrayBuffer 中提到过的相同，调用伴生对象模版类中的 apply 方法。

添加元素：使用 + 方法，返回一个新的 Set。

合并集合： 使用 ++ 方法，合并时去重，返回一个新的 Set，结果仍然无序。

删除元素： 使用 - 方法，返回一个新的 Set，不包含 remove 的元素。

```Scala
// 创建集合
val set1 = Set(1, 2, 3)
println(set1)

// 添加元素
val set2 = set1 + 6
println(set2)

// 合并集合
val set3 = Set(1, 10, 100)
val set4 = set3 ++ set1
println(set4)

// 删除元素
val set5 = set4 - 100
println(set5)


--------  Output  --------
Set(1, 2, 3)
Set(1, 2, 3, 6)
Set(10, 1, 2, 3, 100)
Set(10, 1, 2, 3)
```



2）可变 Set

不同于 Array 和 List 可变与不可变的集合可以直接用名字区分开，Set 声明为可变集合需要显示的声明 mutable.Set，导入可变Set的包。

上面对不可变 Set 的操作方法都适用于可变 Set，用原集合接收返回的集合就可以实现在原集合上进行增删的效果（ += / -= ）；可变集合对不可变集合的操作方法都做了封装，更建议使用封装后的方法来操作可变集合，以此加以区分。

创建集合：与不可变Set唯一区别是在 Set 前声明mutable。

添加元素：使用 += 或 add 方法，将元素加入原集合中，add 方法 对 += 方法进行封装，如果待添加元素已经存在于原集合中返回 false。

合并集合： 使用 ++= 方法，将另外一个集合合并到当前集合中并去重。

删除元素： 使用 -= 或 remove 方法，从原集合中删除指定元素，remove 方法 对 -= 方法进行封装，如果待删除元素不存在于原集合中返回false。

```Scala
// 创建集合
val set1 = mutable.Set(10, 13, 16, 10, 28, 34)
println(set1)
println("===============================")

// 添加元素
val set2 = set1 + 11
println(set1)
println(set2)

set1 += 11
println(set1)

val flag1 = set1.add(20)
println(flag1)
println(set1)
println("===============================")

// 删除元素
set1 -= 10
println(set1)
val flag2 = set1.remove(10)
println(flag2)
println(set1)
println("===============================")

// 合并集合
val set3 = mutable.Set(1, 2, 3, 16, 28)
val set4 = set1 ++ set3
println(set4)
set1 ++= set3
println(set1)


--------  Output  --------
Set(16, 13, 34, 10, 28)
===============================
Set(16, 13, 34, 10, 28)
Set(16, 13, 34, 10, 28, 11)
Set(16, 13, 34, 10, 28, 11)
true
Set(16, 13, 34, 20, 10, 28, 11)
===============================
Set(16, 13, 34, 20, 28, 11)
false
Set(16, 13, 34, 20, 28, 11)
===============================
Set(1, 16, 13, 34, 20, 2, 3, 28, 11)
Set(1, 16, 13, 34, 20, 2, 3, 28, 11)
```



### Map

Key-Value集合，默认为不可变的 Map。

1）不可变 Map

创建集合：同Set只能通过伴生对象模版类的 apply 方法创建集合，但 Map 集合与其它常规集合不同，Map在构造时需要接收键值对，因此它有自己的模版类。

遍历集合：可以直接 print，也可以用 foreach 遍历，会将 KEY 和 VALUE 结合成一个元组。

取集合中元素：使用 Map 的 get 方法，返回内容为 Option 类型，为了避免空指针异常将返回结果包装成 Option，Option 本身是一个抽象类，它有两个实现 Some 和 None，Some表示有值， None 表示空值，两个类都实现了 Option 的 get 方法；若返回 Some，可以通过 get 取到对应的 VALUE，若返回 None，执行 get 方法会抛出异常；如果不想抛出异常，Map 提供了 getOrElse方法，接受两个参数分别为 KEY 和找不到对应 VALUE 时应该返回的内容；但其实 getOrElse 还是相对麻烦，Map 提供了 apply 方法对 getOrElse 做了进一步封装，apply方法如下：

```Scala
def apply(key: K): V = get(key) match {
	case None => default(key)
  case Some(value) => value
}
```

不可变Map操作示例代码如下：

```Scala
// 创建集合
val map1 = Map.apply(16 -> "Ramsey", 7 -> "Saka", 10 -> "Rowe")
println(map1)

// 遍历集合
map1.foreach(println);
for (kv <- map1) println(kv) // Tuple

// 取Map中所有key
for (key <- map1.keys) {
println(s"${key} ---> ${map1.get(key)}")
}

println("7: " + map1.get(8))
println("16: " + map1.get(16).get)
println("10: " + map1.getOrElse(9, 0))

println("7: " + map1(7))


--------  Output  --------
Map(16 -> Ramsey, 7 -> Saka, 10 -> Rowe)
(16,Ramsey)
(7,Saka)
(10,Rowe)
(16,Ramsey)
(7,Saka)
(10,Rowe)
16 ---> Some(Ramsey)
7 ---> Some(Saka)
10 ---> Some(Rowe)
7: None
16: Ramsey
10: 0
7: Saka
```



2）可变Map

可变Map的底层实际上是一个HashMap，操作和其它集合大同小异，直接看代码

```Scala
// 创建集合
val map1 = mutable.Map(16 -> "Ramsey", 7 -> "Saka", 10 -> "Rowe")

// 添加元素
map1.put(14, "Auba")
println(map1)
map1 += ((9, "Laca"), (1, "Leno"))
println(map1)


// 删除元素
map1.remove(9)
println(map1.getOrElse(9, 0))
map1 -= 1
println(map1)

// 修改元素
map1.update(10, "S.Rowe")

// 合并集合
var map2 = Map(34 -> "Xhaka", 5 -> "Partey", 3 -> "Thierney", 14 -> "Aubameyang")
map1 ++= map2
println(map1)
println(map2)


--------  Output  --------
Map(14 -> Auba, 7 -> Saka, 16 -> Ramsey, 10 -> Rowe)
Map(14 -> Auba, 7 -> Saka, 16 -> Ramsey, 1 -> Leno, 10 -> Rowe, 9 -> Laca)
0
Map(14 -> Auba, 7 -> Saka, 16 -> Ramsey, 10 -> Rowe)
Map(5 -> Partey, 14 -> Aubameyang, 34 -> Xhaka, 7 -> Saka, 16 -> Ramsey, 10 -> S.Rowe, 3 -> Thierney)
Map(34 -> Xhaka, 5 -> Partey, 3 -> Thierney, 14 -> Aubameyang)
```

put 方法底层也是 update 方法；合并集合时若有重复 KEY 的元素，会对原集合该 KEY 对应的 VALUE 进行更新。



### 元组

元组将相同或不同数据类型的元素封装为一个整体。

上一节在介绍 Map 的时候提到了Map中每一项是 KEY 和 VALUE 组合成的一个二元元组，数据类型是Tuple2，元组的底层有Tuple1 - Tuple22，所以最多只能有22个元素。

元组用小括号声明，逗号分隔各元素；可以用下划线加序号访问元组中每一个元素，也可以使用元组引入的特质中实现的迭代器去访问每个元素；每一个TupleX都重写了toString方法。

```Scala
// 1. 创建元组
val tuple: (String, Int, Char, Boolean) = ("ssss", 22, 'j', true)
println(tuple)

// 2. 访问元组
println(tuple._1)
println(tuple._2)
println(tuple._3)
println(tuple._4)

println("==========")

// 3. 遍历元组数据
for (elem <- tuple.productIterator)
println(elem)


--------  Output  --------
(ssss,22,j,true)
ssss
22
j
true
==========
ssss
22
j
true
```



### 队列

操作受限的列表，同样分可变和不可变两种，默认为不可变。

可变的Queue是一个普通的类，可以直接用new去创建；Queue同样有伴生对象，也可以用模版类中的apply方法创建。

```scala
// 创建队列
val queue = new mutable.Queue[Int]()
val queue1 = mutable.Queue(1, 2, 3)
println(queue1)

queue.enqueue(1, 8, 10)
queue.dequeue()
println(queue)


--------  Output  --------
Queue(1, 2, 3)
Queue(8, 10)
```

不可变Queue是一个密封类，只能通过伴生对象的方法创建。

```Scala
val queue1 = Queue[Int](1, 2, 3)
println(queue1)
val queue2 = queue1.enqueue("10")
println(queue2)


--------  Output  --------
Queue(1, 2, 3)
Queue(1, 2, 3, 10)
```



### 并行集合

充分利用多核CPU，Scala提供并行集合，可进行并行计算。

只需要加 .par

```Scala
val result1: immutable.IndexedSeq[Long] = (1 to 100).map(
	x => Thread.currentThread().getId
)
println(result1)
val result2: ParSeq[Long] = (1 to 100).par.map(
	x => Thread.currentThread().getId
)
println(result2)


--------  Output  --------
Vector(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
ParVector(11, 11, 11, 11, 11, 11, 17, 17, 17, 17, 17, 17, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 17, 16, 16, 14, 14, 14, 13, 18, 18, 15, 15, 16, 16, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18, 18)
```





至此，Scala 集合的三大类型介绍完毕，不打算在接下来介绍集合的常用方法，根据我个人的编程经验，很多API的使用都是一个熟能生巧的过程，而且每个API存在即合理，因此要用到的时候再去百度或者查API文档，更有利于记忆，还可以去积累自己的一个API代码库。