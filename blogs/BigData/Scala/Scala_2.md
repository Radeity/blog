---
title: Scala 入门学习（二）： 运算符、流程控制
date: 2021-08-07
tags:
 - Scala
sidebar: auto
categories:
 -  大数据
---

> 本系列文章会着重介绍Scala与Java的不同点，较适合学习过Java的人阅读。
> 
> 本篇文章介绍了Scala的运算符、流程控制。

**运算符**

Scala中的比较运算符 == 与Java略有不同。首先回顾Java中的 == ，该运算符在Java中比较的是两个引用的地址是否相等，equals方法比较两个引用的属性值是否相等，自己定义的类中也可以重写equals方法。

```Java
String s1 = "season";
String s2 = new String("season");
System.out.println(s1 == s2);
System.out.println(s1.equals(s2));


--------  Output  --------
false
true
```

Scala中 == 等价于调用了equals方法，如果要判断引用地址是否相同应该用eq()。

```Scala
val s1: String = "hello"
val s2: String = new String("hello")
println(s1 == s1)
println(s1.equals(s2))
println(s1.eq(s2))
println()

val stu1 = new Student("aaron",22)
val stu2 = new Student("aaron",22)
println(stu1 == stu2)
println(stu1.equals(stu2))
println(stu1.eq(stu2))


--------  Output  --------
true
true
false

false
false
false
```

发现stu1 == stu2的判别结果仍然给了false，因为我们之前自定义的Student类中没有重写equals方法，无法做出判断，重写如下：

```Scala
override def equals(obj: Any): Boolean = {
  val x = obj.asInstanceOf[Student]
  if(x.name == this.name && x.age == this.age)
  	return true
  else
  	return false
}
```

再次执行上面的测试程序，第二组的测试结果便与第一组相同，前两行为true，第三行为false。

Java中**自增（++）、 自减（--）**运算符在Scala中**没有**，可以用+=和-=运算符代替，a+=b的逻辑是a与b相加后结果赋值给a，上面讲类型转换提到过Byte和Short相互计算都会转为Int，因此如果a是Byte或Short，a+=b会报错，**不能把Int赋值给Byte或Short**，此时需要修改为a = (a+b).toByte。



**条件分支控制**

Scala的条件分支语句有返回值，为条件判断代码块的最后一行，这一特性使其可以取代Java的三元表达式 **a?b:c  <=>  if (a) b else c**。

```Scala
val age: Int = StdIn.readInt()
val state = if(age < 6) {
	println(age)
	"童年"
} else if(age<18) "青少年" else age
println(state)

val res = if (age < 18) "未成年" else "成年" // 取代三元表达式
println(res)


--------  Input  --------
5
--------  Output  --------
5
童年
未成年
```

**For循环控制**

1. 范围遍历

   ```Scala
   for (i <- 1 to 5) {
   	println(s"${i} Hello World!")
   }
   
   
   --------  Output  --------
   1 Hello World!
   2 Hello World!
   3 Hello World!
   4 Hello World!
   5 Hello World!
   ```

   1是Int类型，Scala有**隐式转换**的特性，将Int转为Int的一个包装类RichInt，执行RichInt的to方法，也可以写作1.to(5)，该方法返回了步长为1从1到5的**Range集合**，<-就是将集合内的值依次赋值给i，便得到了上面的输出结果。集合和隐式转换会在后面做介绍。

   如果将上面声明for语句中的to改为until，则Range集合从1-4，不包含5，从源码进行一下解读，to和until的方法定义如下：

   ```scala
   def until(end: Int): Range = Range(self, end)
   def to(end: Int): Range.Inclusive = Range.inclusive(self, end)
   ```

   我们看到until直接调用了Range，而to调用了继承Range的一个final类Inclusive，下面的Inclusive源码中可以发现。它对属性isInclusive赋值为true，通过变量名可以判断它是决定是否包含边界的变量，这个变量在Range中的默认值是false，这也解释了为什么until直接调用Range时不包含边界。

   ```Scala
   final class Inclusive(start: Int, end: Int, step: Int) extends Range(start, end, step) {
     //    override def par = new ParRange(this)
     override def isInclusive = true
     override protected def copy(start: Int, end: Int, step: Int): Range = new Inclusive(start, end, step)
   }
   ```

2. 集合遍历

   范围遍历中 1 to 5 实际上返回了一个Range集合，将其直接替换为其它集合也可以实现遍历，Scala中通过 <- 取集合元素和Java中的 : 类似。

   ```Scala
   for (i <- Array(11, 22, 33)) {
   	println(i)
   }
   
   
   --------  Output  --------
   11
   22
   33
   ```

3. 循环守卫

   类似continue的功能，在循环声明中最后附加一个条件判断，满足条件才能执行当前循环。

   ```Scala
   for (i <- 1 to 5 if i != 2) {
   	println(s"${i} Hello World!")
   }
   
   
   --------  Output  --------
   1 Hello World!
   3 Hello World!
   4 Hello World!
   5 Hello World!
   ```

4. 循环步长

   Range类中定义了by方法可以指定循环步长。

   ```Scala
   def by(step: Int): Range = copy(start, end, step)
   ```

   从start开始依次加步长step获得下一个元素，若步长小于零则需要start大于end。另外，Range中还定义了reverse方法将集合反转，10到1步长-1可以替换为1到10反转后步长为1；这里遇到一个小问题，如果写作 i <- 1 to 10 reverse by -2 会报错，只能写完整改成 i <- (1 to 10).reverse.by(-2)，这个也许是编译器的问题？后面如果知道答案了会进行补充。

   ```scala
   for (i <- 1 to 10 by 2) {
     println(s"${i} Hello World!")
   }
   println("=================")
   
   for (i <- 10 to 1 by -2) {
     println(s"${i} Hello World!")
   }
   println("=================")
   
   for (i <- 1 to 10 by 2 reverse) {
     println(s"${i} Hello World!")
   }
   
   //    for (i <- 1 to 10 reverse by -2) {
   //      println(s"${i} Hello World!")
   //    }		//	error :Error:(19, 33) not found: value by for (i <- (1 to 10) reverse by -2 ) {
   
   --------  Output  --------
   1 Hello World!
   3 Hello World!
   5 Hello World!
   7 Hello World!
   9 Hello World!
   =================
   10 Hello World!
   8 Hello World!
   6 Hello World!
   4 Hello World!
   2 Hello World!
   =================
   9 Hello World!
   7 Hello World!
   5 Hello World!
   3 Hello World!
   1 Hello World!
   
   ```

5. 循环嵌套

   Scala提供了更简洁的方式实现多层循环。

   ```Scala
   for (i <- 1 to 9; j <- 1 to i) {
     print(s"${i} * ${j} = ${i*j}\t")
     if(i == j)
     	println()
   }
   
   
   --------  Output  --------
   1 * 1 = 1	
   2 * 1 = 2	2 * 2 = 4	
   3 * 1 = 3	3 * 2 = 6	3 * 3 = 9	
   4 * 1 = 4	4 * 2 = 8	4 * 3 = 12	4 * 4 = 16	
   5 * 1 = 5	5 * 2 = 10	5 * 3 = 15	5 * 4 = 20	5 * 5 = 25	
   6 * 1 = 6	6 * 2 = 12	6 * 3 = 18	6 * 4 = 24	6 * 5 = 30	6 * 6 = 36	
   7 * 1 = 7	7 * 2 = 14	7 * 3 = 21	7 * 4 = 28	7 * 5 = 35	7 * 6 = 42	7 * 7 = 49	
   8 * 1 = 8	8 * 2 = 16	8 * 3 = 24	8 * 4 = 32	8 * 5 = 40	8 * 6 = 48	8 * 7 = 56	8 * 8 = 64	
   9 * 1 = 9	9 * 2 = 18	9 * 3 = 27	9 * 4 = 36	9 * 5 = 45	9 * 6 = 54	9 * 7 = 63	9 * 8 = 72	9 * 9 = 81	
   ```

6. 引入变量

   引入变量的形式和上面循环嵌套比较相似，都是在声明循环时用分号隔开了两个变量，**注意区分**，引入变量是根据现有的变量推出一个变量，而循环嵌套是再定义一个变量从一个范围中取值。

   ```Scala
   for (i <- 1 to 3; j = 4 - i) {
   	println(s"${i}, ${j}")
   }
   
   
   --------  Output  --------
   1, 3
   2, 2
   3, 1
   ```

   引入多个变量时，可以用花括号括起推导式，推导式间换行，且可以去掉分号。

   ```Scala
   for {i <- 1 to 3
        j = 4 - i
        k = i + 2} {
     println(s"${i}, ${j}, ${k}")
   }
   
   
   --------  Output  --------
   1, 3, 3
   2, 2, 4
   3, 1, 5
   ```

7. 循环返回值

   不同于条件判断返回值在最后一行，for循环默认返回类型都是Unit（空值）。使用**yield**关键字对声明for时所遍历集合的每一个元素做计算处理并将结果保存在Vector中。

   ```Scala
   val res = for(i <- 1 to 10) yield i*i*i
   	println(res)
   
   
   --------  Output  --------
   Vector(1, 8, 27, 64, 125, 216, 343, 512, 729, 1000)
   ```



**while循环控制**

while循环控制在Scala中不推荐，while没有返回值，整个while语句是Unit类型。因为没有返回值，通过while计算结果时需要将变量修饰在while循环外部，Scala在大数据领域的应用较多，经常会涉及一些并发操作，修改循环外变量有潜在风险。



**循环中断**

为了更好的适应函数式编程，Scala中去掉了continue和break关键字，使用函数式风格 **Breaks.breakable() **进行代替。下面给出了两种利用Break类实现break的方式，要注意代码中的break不是关键字，而是break()方法，没有参数因此省略了括号。

```Scala
import scala.util.control.Breaks._

object Test_Break {
  def main(args: Array[String]): Unit = {

    breakable (
      for (i <- 0 until 5) {
        if (i == 3)
          break
        println(i)
      }
    )
    println("这是循环外代码")

    tryBreakable (
      for (i <- 0 until 5) {
        if (i == 3)
          break
        println(i)
      }
    ) catchBreak (
      println("现在跳出循环了")
    )
    println("这是循环外代码")

  }
}


--------  Output  --------
0
1
2
这是循环外代码
0
1
2
现在跳出循环了
这是循环外代码
```




