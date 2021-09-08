---
title: RDD——转换算子
date: 2021-09-08
tags:
 - Spark
sidebar: auto
categories:
 -  大数据
---


RDD算子分为转换算子和行动算子，本篇文章将会对前者进行介绍。

转换算子：旧的RDD封装上方法包装为新的RDD；分为Value类型、双Value类型和Key-Value类型。

### Value类型

1. Map：类似Scala中的集合操作，对RDD中数据单值的做映射。若分区数为1，则需要前一个数据执行完全部逻辑才可以执行下一个（有序）；若分区数不为1，每个分区内数据执行仍然是有序的，但不同分区间的数据操作可以并行执行（无序）。

   ```scala
   object Spark01_RDD_Operator_Transform_Par {
     def main(args: Array[String]): Unit = {
       val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
       val sc = new SparkContext(sparkConf)
   
       // TODO 算子 - map
       val rdd: RDD[Int] = sc.makeRDD(List(1, 2, 3, 4), 2)
   
       val mapRDD: RDD[Int] = rdd.map(
         (num: Int) => {
           println("##### num = " + num)
           num
         }
       )
   
       val mapRDD1: RDD[Int] = mapRDD.map(
         (num: Int) => {
           println(">>>> num = " + num)
           num
         }
       )
       mapRDD1.collect()
       sc.stop()
     }
   }
   
   
   --------  Output  --------
   ##### num = 3
   ##### num = 1
   >>>> num = 3
   >>>> num = 1
   ##### num = 4
   ##### num = 2
   >>>> num = 4
   >>>> num = 2
   ```

   上例中1和2在一个分区，3和4在一个分区，1和3的每一个逻辑运算谁先执行不确定，2和4每一个逻辑运算谁先执行也不确定，但2一定在1后，4一定在3后。

2. mapPartitions：将一个分区的数据全部加载到内存中进行操作；需要传对一个分区的迭代器进行操作并返回一个迭代器的匿名函数作为参数f；内存中进行批处理效率高，但由于内存中有一个分区数据的对象引用，全部处理完也不会立即释放内存资源，因此不适用于内存小数据量大的逻辑操作。

   ```scala
   def mapPartitions[U: ClassTag](
   	f: Iterator[T] => Iterator[U],
   	preservesPartitioning: Boolean = false): RDD[U] = withScope {...}
   ```

   注意：匿名函数必须返回一个Iterator，若目的为求该分区的最小值，应该在返回时将该最小值封装成迭代器

   ```scala
   val mpRDD: RDD[Int] = rdd.mapPartitions( iter => {
   	// List(iter.max).iterator
   	Iterator(iter.max)
   })
   ```

   mapPartitions 对比 map：

   - mapPartitions是分区为单位的批处理流程，map是一个一个数据的串行操作，mapPartitions不用多次做内存IO，效率更高。
   - mapPartitions是传入迭代器返回迭代器，可以对一个分区数据的数据量进行修改，map只能一一做映射，最多仅能修改类型。

3. mapPartitionsWithIndex：相比mapPartitions传入的匿名函数多了一个分区号作为参数。

   ```scala
   object Spark03_RDD_Operator_Transform {
     def main(args: Array[String]): Unit = {
       val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
       val sc = new SparkContext(sparkConf)
       
       // TODO 算子 - mapPartitionsWithIndex
       val rdd: RDD[Int] = sc.makeRDD(List(1, 2, 3, 4))
   
       val mpRDD = rdd.mapPartitionsWithIndex(
         (index, iter) => iter.map((index, _)) // 每行数据映射为（分区号，数据）的格式
       )
       mpRDD.collect().foreach(println)
       
       sc.stop()
     }
   }
   
   
   --------  Output  --------
   (1,1)
   (3,2)
   (5,3)
   (7,4)
   ```

4. flatMap：先map后做扁平化操作，map映射函数的结果只要是一个可迭代集合就可以进行后续的扁平化操作。flatMap底层也是通过mapPartitions实现，因此分区不会改变，同一分区的数据经过flatMap仍然在同一分区。

   ```scala
   object Spark04_RDD_Operator_Transform {
     def main(args: Array[String]): Unit = {
       val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
       val sc = new SparkContext(sparkConf)
   
       // TODO 算子 - flatMap
       val rdd: RDD[Any] = sc.makeRDD(List(
         List(1, 2), List(3, 4), 5
       ))
   
   //    val flatRDD: RDD[Int] = rdd.flatMap(list => list)
       val flatRDD = rdd.flatMap(
         data => data match {
           case list: List[_] => list
           case x => List(x)
         })
   
       flatRDD.collect().foreach(println)
       
       sc.stop()
     } 
   }
   
   
   --------  Output  --------
   1
   2
   3
   4
   5
   ```

5. glom：不需要传任何参数，将一个分区的数据封装到一个数组放在内存中，由于是数组，操作更加灵活。  

   val glomRDD: RDD[Array[Int]] = rdd.glom()

6. groupBy：分组，和Scala集合的groupBy操作相同，传入匿名函数返回key，相同key的数据划分到一个分组中。groupBy对数据打乱根据新规则重新分组，同一组的数据存放在同一分区中。

   ```scala
   object Spark06_RDD_Operator_Transform {
     def main(args: Array[String]): Unit = {
       val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
       val sc = new SparkContext(sparkConf)
   
       // TODO 算子 - groupBy
       val rdd: RDD[String] = sc.makeRDD(List("Hello", "Style", "Study", "Hi"),2)
       val groupRDD: RDD[(Char, Iterable[String])] = rdd.groupBy(_.charAt(0))
       println(groupRDD.collect().foreach(println))
   
       sc.stop()
     }
   }
   
   
   --------  Output  --------
   (H,CompactBuffer(Hello, Hi))
   (S,CompactBuffer(Style, Study))
   ```

7. filter：过滤，符合规则的数据保留。过滤操作可能造成**数据倾斜**，两个分区数据量差距较大。

8. sample：抽样 

   ```scala
   def sample(
     		// 抽取后是否放回
         withReplacement: Boolean,		
     		// 每条数据被抽取的概率
         fraction: Double,			
     		// 抽取数据的随机种子    
         seed: Long = Utils.random.nextLong): RDD[T] = {}
   ```

   seed（随机种子）决定了每个元素被抽出的概率，参数不传seed会根据系统时间生成一个随机种子。若withReplacement为false，则抽取不放回，抽出概率大于fraction则抽取出；若withReplacement为true，则抽取后放回，fraction表示每条数据被抽取的可能次数；

   用途：有时shuffle打乱数据重新建立分区，会造成数据倾斜，分区数据量差距大，并行计算效率降低；sample可以用来判断数据倾斜，发现问题后再用特定手段进行处理。

9. distinct：去重。Scala中集合去重底层用到了HashSet；Spark中去重底层实现如下：

   ```scala
   map(x => (x, null)).reduceByKey((x, _) => x, numPartitions).map(_._1)
   
   // 1, 2, 3, 4, 1, 2, 3, 4
   // map:
   // (1, null), (2, null), (3, null), (4, null), (1, null), (2, null), (3, null), (4, null)
   // reduceByKey: 
   // (1, null) (1, null)
   // (null, null) => null
   // (1, null)
   // map:
   // 1
   ```

   reduceByKey是将一个元组当作 key-value 键值对，相同key的数据两两对value进行reduce操作，因此reduceByKey和reduce一样需要传接收两个参数的匿名函数表示reduce阶段进行的操作。

10. coalesce：缩减（合并）分区。若过滤后每个分区的数据量小，划分成两个任务浪费资源。默认情况下不会shuffle重组（shuffle: Boolean = false），同一个分区的数据coalesce后在同一分区，可能出现数据倾斜，可以传参数令shuffle=true允许分区数据重组。coalesce也可以扩大分区，但若shuffle参数为false，该操作无意义，同一个分区内数据不能被分开。

    repartition：扩大分区。其底层就直接调用了shuffle为true的coalesce。

    ```scala
    def repartition(numPartitions: Int)(implicit ord: Ordering[T] = null): RDD[T] = withScope {
      coalesce(numPartitions, shuffle = true)
    }
    ```

11. sortBy：根据指定规则对数据排序，默认升序排序，且会进行shuffle重组。

    ```scala
      def sortBy[K](
          f: (T) => K,	// 从每个元素中获取排序的参照项
          ascending: Boolean = true,	// 是否升序排序
          numPartitions: Int = this.partitions.length)	// 排序后分区数
    ```

    

### 双Value类型

两个集合进行交（intersection）、并（union）、差（subtract）、拉链（zip）计算，拉链为两个集合对应位置打包成键值对的形式。

  ```scala
  object Spark13_RDD_Operator_Transform {
    def main(args: Array[String]): Unit = {
      val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
      val sc = new SparkContext(sparkConf)
  
      // TODO 算子 - 双 Value
      val rdd1: RDD[Int] = sc.makeRDD(List(1,2,3,4))
      val rdd2: RDD[Int] = sc.makeRDD(List(3,4,5,6))
  
      // 交集
      val rdd3: RDD[Int] = rdd1.intersection(rdd2)
      println(rdd3.collect.mkString(", "))
  
      // 并集
      val rdd4: RDD[Int] = rdd1.union(rdd2)
      println(rdd4.collect.mkString(", "))
  
      // 差集
      val rdd5: RDD[Int] = rdd1.subtract(rdd2)
      println(rdd5.collect.mkString(", "))
  
      // 拉链
      val rdd6: RDD[(Int, Int)] = rdd1.zip(rdd2)
      println(rdd6.collect.mkString(", "))
  
  
      sc.stop()
    }
  }
  
  
  --------  Output  --------
  3, 4
  1, 2, 3, 4, 3, 4, 5, 6
  1, 2
  (1,3), (2,4), (3,5), (4,6)
  ```

  交并差要求两数据源的数据类型必须一致，拉链无此要求。

  拉链操作要求两个数据源分区数量必须保持一致，且分区中数据数量必须保持一致。

  

### Key-Value类型

1. partitionBy：根据指定规则（分区器）重新分区，Spark的默认分区器是HashPartitioner；partitionBy实则 是PairRDDFunctions的函数，并不是RDD的函数，RDD的伴生对象提供了K-V类型的隐式函数，RDD在调用partitionBy时会隐式转换为PairRDDFunctions。

   调用partitionBy方法时会判断分区器和分区数量是否都相同，都相同则不重新进行分区，直接返回它自己。

   可以自定义分区器改变分区方式。

2. reduceByKey：相同的key分组对value进行聚合操作（两两聚合）。若某个key没有两条数据则不会进行聚合操作，直接输出结果。

   不传分区器则 使用默认分区器（Hash分区器），通过对key求hashcode模分区个数得到分区号。

3. groupByKey：相同key的数据分为一组。rdd.groupBy( \_._1 )也能实现groupByKey的功能，但两者返回结果不同。

   ```scala
   val rdd: RDD[(String, Int)] = sc.makeRDD(List(
   	("a", 1), ("a", 2), ("a", 3), ("b", 4)
   ))
   
   val groupRDD: RDD[(String, Iterable[Int])] = rdd.groupByKey()
   val groupRDD1: RDD[(String, Iterable[(String, Int)])] = rdd.groupBy(_._1)
   ```

   spark中shuffle操作必须**落盘处理**，将过程写入磁盘文件，不能在内存中等待不同数据分区的数据shuffle重组到一个分区，数据量大会导致内存溢出，落盘会进行多次io操作，性能低。

   reduceByKey和groupByKey都要进行shuffle操作， 前者会在shuffle前对分区内数据进行预聚合，减少落盘数据量，性能跟高；若不需要聚合还是优先考虑groupByKey。

4. aggregateByKey：分区内和分区间聚合规则独立设定。reduceByKey规则相同。

   ```scala
   def aggregateByKey[U: ClassTag](zeroValue: U)(seqOp: (U, V) => U,
       combOp: (U, U) => U): RDD[(K, U)] = self.withScope {
     aggregateByKey(zeroValue, defaultPartitioner(self))(seqOp, combOp)
   }
   ```

   柯里化形式定义

   第一个参数列表zeroValue表示需要传递一个初始值，分区内和分区间都在此初始值的基础上迭代的进行聚合，聚合结果的value数据类型取决于该初始值的数据类型。

   第二个参数列表中，第一个参数seqOp表示分区内计算规则；第二个参数combOp表示分区间计算规则。

   ```scala
   object Spark17_RDD_Operator_Transform {
     def main(args: Array[String]): Unit = {
       val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
       val sc = new SparkContext(sparkConf)
   
       // TODO 算子 - Key - Value
       val rdd: RDD[(String, Int)] = sc.makeRDD(List(
         ("a", 1), ("a", 2), ("a", 3), ("a", 4)
       ), 2)
   
       rdd.aggregateByKey(0)(
         (x,y)=>math.max(x, y),
         (x,y)=>x+y
       ).collect.foreach(println
                         
       
       sc.stop()
     }
   }
   
   
   --------  Output  --------
   (a,6)
   ```

    若分区内和分区间聚合规则相同，可以用foldByKey代替，第一个参数传初始值，第二个参数传聚合规则。

5. mapValues：K-V类型RDD对Value进行map操作。

6. combineByKey：将每个Key第一个出现的数据进行形式的转换（映射）后聚合。

   例：求每个Key平均值

   ```scala
   object Spark19_RDD_Operator_Transform {
     def main(args: Array[String]): Unit = {
       val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
       val sc = new SparkContext(sparkConf)
   
       // TODO 算子 - Key - Value
       val list: List[(String, Int)] = List(("a", 88), ("b", 95), ("a", 91), ("b", 93),
         ("a", 95), ("b", 98))
       val rdd: RDD[(String, Int)] = sc.makeRDD(list, 2)
   
       rdd.combineByKey(
         (_, 1),
         (t:(Int, Int), v) => (t._1+v, t._2+1),
         (t1:(Int, Int), t2:(Int, Int)) => (t1._1+t2._1, t1._2+t2._2)
       ).mapValues(t => t._1 / t._2).collect.foreach(println)
   
       sc.stop()
     }
   }
   
   
   --------  Output  --------
   (b,95)
   (a,91)
   ```

   注意：combineByKey传参分区内分区间聚合逻辑需要声明类型，函数执行时先做了映射才确定的聚合操作目标数据的类型，编译器无法自动推断出类型。

   总结：reduceByKey、foldByKey、aggregateByKey、combineByKey四个算子都可以做K-V类型RDD的聚合，它们在底层均调用了combineByKeyWithClassTag方法，四者区别如下：

   - reduceByKey: 相同 key 的第一个数据不进行任何计算，分区内和分区间计算规则相同。 
   - FoldByKey: 相同 key 的第一个数据和初始值进行分区内计算，分区内和分区间计算规则相同。
   - AggregateByKey: 相同 key 的第一个数据和初始值进行分区内计算，分区内和分区间计算规则可以不相同。
   - CombineByKey: 当计算时，发现数据结构不满足要求时，可以将第一个数据结构转换；分区内和分区间计算规则不相同。

7. join：类似对相同key数据的value进行自然连接。(K, V)和(K, W)类型RDD相同key的value会连接成元组得到(K, (V, W))类型RDD。若两数据源没有匹配上数据不会出现在结果中；若有多个相同key，可能会出现“笛卡尔积”形式，两两进行匹配。

8. leftOuterJoin：类似对相同key数据的value进行左外连接。得到value元组的左边一定有值，右边是若匹配成功为Option的Some对象，否则为None对象。

9. rightOuterJoin：类似对相同key数据的value进行右外连接。得到value元组的右边一定有值，左边是若匹配成功为Option的Some对象，否则为None对象。

   ```scala
   object Spark22_RDD_Operator_Transform {
     def main(args: Array[String]): Unit = {
       val sparkConf: SparkConf = new SparkConf().setMaster("local[*]").setAppName("RDD")
       val sc = new SparkContext(sparkConf)
   
       // TODO 算子 - Key - Value
       val rdd: RDD[(String, Int)] = sc.makeRDD(List(
         ("a", 88), ("b", 95), ("c", 91),
       ))
   
       val rdd1: RDD[(String, Int)] = sc.makeRDD(List(
         ("a", 93), ("b", 95), ("d", 98)
       ))
   
       println(
         rdd.join(rdd1).collect.mkString(", ")
       )
       println(
         rdd.leftOuterJoin(rdd1).collect.mkString(", ")
       )
       println(
         rdd.rightOuterJoin(rdd1).collect.mkString(", ")
       )
   
       sc.stop()
     }
   }
   
   
   --------  Output  --------
   (a,(88,93)), (b,(95,95))
   (a,(88,Some(93))), (b,(95,Some(95))), (c,(91,None))
   (a,(Some(88),93)), (b,(Some(95),95)), (d,(None,98))
   ```

10. cogroup：相同key的数据分组后连接。最多可以将四个RDD进行分组后连接，每个RDD内部相同key的数据对应value打包，不同RDD间相同key对应value打包后的结果合并成元组；RDD[(**K**, **V1**)]与RDD[(**K**, **V2**)]执行cogroup后得到RDD[(**K**, (**Iterable[V1]**, **Iterable[V2]**))]。



