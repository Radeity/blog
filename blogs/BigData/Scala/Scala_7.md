---
title: Scala 入门学习（七）：模式匹配
date: 2021-08-18
tags:
 - Scala
sidebar: auto
categories:
 -  大数据
---

> 本系列文章会着重介绍Scala与Java的不同点，较适合学习过Java的人阅读。
> 
> 本篇文章会介绍Scala中应用十分普遍的模式匹配。

## Scala —— 模式匹配

Java 中 switch ... case，Scala中替换为 match ... case；



### **基本定义**

case从上到下依次匹配，匹配成功则执行 case 内代码块， => 后声明代码块可以不用加{}，下一个case前的代码可以都当作当前 case 的代码执行，同样，该代码块的最后一行为返回值；匹配都不成功，执行最后的 case _ ，类似Java default，若没定义 case _ 分支，会抛出 MatchError。

```Scala
def matchPlayer(x: Int) = x match {
	case 7 => "Saka"
	case 8 => "Aaron"
	case 10 => "Rowe"
	case _ => "other"
}
println(matchPlayer(10))
println(matchPlayer(20))



--------  Output  --------
Rowe
other
```



### **模式守卫**

若匹配的不是具体值，而是一个范围时，可以使用模式守卫。看过之前的文章应该对守卫这个词不陌生，之前讲过Scala在for中有循环守卫。

```Scala
def abs(x: Int) = x match {
  case i if i >= 0 => i
  case i if i < 0 => -i
}
println(abs(10))
println(abs(-16))


--------  Output  --------
10
16
```



### **模式匹配类型**

**匹配常量：**

参见上面基本定义中的例子，程序运行时会将待匹配的变量值从上到下依次进行 case 后值的比对，若相同则匹配成功。



**匹配类型：**

case 关键字后是一个指定类型的临时变量，程序会将 x 依次对 case 后临时变量赋值，类型相同则赋值成功，即匹配成功。若不想赋值到临时变量，仅匹配类型，可以用下划线代替临时变量名；匹配的代码块中可以直接使用 x ，但如果 x 在模式匹配后还要使用，谨慎在代码块中对其进行修改。

```Scala
def descriveType(x: Any): String = x match {
  case i: Int => "Int"
  case _: String => "String hello"
  case m: List[String] => "List"
  case c: Array[Int] => "Array[Int]"
  case a => "something else "
}
println(descriveType(5))
println(descriveType("Rowe"))
println(descriveType(List(1,2,3)))
println(descriveType(Array("Laka","Saka")))


--------  Output  --------
Int
String helloRowe
List
something else
```

代码中模式匹配 List 时发现传入的是 List[Int]，和定义的匹配类型 List[String] 并不相同但仍然匹配成功，这是由于 Scala 和 Java 一样在编译时会对泛型集合进行**类型擦除**，编译器只能看到对象的类型，不能识别泛型，通常可以用 TypeTag 解决该问题，TypeTag的用法会在日后进行整理；（https://stackoverflow.com/questions/12218641/scala-what-is-a-typetag-and-how-do-i-use-it）所以代码中，List[String] 和 List[Int] 编译器都只会判断为是一个 List，类型相同。

Array不同于 List、Map 等集合，它是 Scala 中很底层的数据类型，非泛型，Array[T] 等价于 Java 中 T[] 数组类型的定义，因此 Array[String] 和 Array[Int] 不会判断为相同类型。



**匹配数组：**

数组内数据类型可以用 _ 作为占位符，_*表示有多个元素。

```Scala
for (arr <- Array (  // 对一个数组集合进行遍历
	Array (0),
	Array (1, 0),
	Array (0, 1, 0),
	Array (1, 1, 0),
	Array (1, 1, 0, 1),
	Array ("hello", "aaron")
) ) { 
  val result = arr match {
 		case Array (0) => "0" //匹配 Array(0) 这个数组
  	case Array (x, y) => x + "," + y //匹配有两个元素的数组，然后将将元素值赋给对应的 x,y
  	case Array (0, _*) => "以 0 开头的数组" //匹配以 0 开头的数组
  	case _ => "something else"
	}
  println ("result = " + result)
}


--------  Output  --------
result = 0
result = 1,0
result = 以 0 开头的数组
result = something else
result = something else
result = hello,aaron
```



**匹配列表：**

对List的模式匹配可以使用上面Array模式匹配的语法；另外，还可以使用List的双冒号运算符，:: 在创建列表或者向列表头部追加元素时使用过，:: 前一定为一个元素，最后一个 :: 的后面一定为List。回顾：val list = 1 :: 10 :: 11 :: Nil

```Scala
val list: List[Int] = List(1, 2, 5, 6, 7)
list match {
  case first :: second :: rest => println(first + "-" +
  second + "-" + rest)
  case _ => println("something else")
}


--------  Output  --------
1-2-List(5, 6, 7)
```



**匹配元组：**

元组和数组匹配基本相同，唯一一个不同是不能使用 _* 表示多个元素，上一章介绍元组提到过每个元组都属于TupleX的数据类型，表示元组内有X个元素，X取值为1到22，这意味着元组是定长的数据类型，因此不能用 _* 这种不确定长度的占位符标志。



**匹配对象：**

若case后直接new一个对象或者用伴生对象的apply方法返回一个对象，无法完成对象的匹配（这里指自定义的对象），对象需要有**拆解**的过程，与apply方法对偶的一个unapply方法实现了拆解，Array、List等集合实际上也是拆解后进行的匹配，它们在底层已经提供了unapply方法，自定义对象需要定义unapply方法；unapply方法返回Option对象，若对象为空则返回None，对象非空则将属性值封装到元组后再包装到Some对象中；实际在进行对象的模式匹配时会先去默认的调用unapply方法。

```Scala
object Test_MatchObject {
  def main(args: Array[String]): Unit = {
    val student = new Student("aaron", 22)

    val result = student match {
      case Student("aaron", 22) => "Aaron, 22"
      case _ => "Something Else"
    }
    println(result)
  }
}

class Student(val name: String, val age: Int)

object Student {
  def apply(name: String, age: Int): Student = new Student(name, age)

  def unapply(student: Student): Option[(String, Int)]  = {
    if (student == null){
      return None
    } else {
      Some((student.name, student.age))
    }
  }
}


--------  Output  --------
Aaron, 22
```

可以使用**样例类**，样例类主构造器的所有参数默认都是当前类的属性，且自动生成了apply和unapply方法。

```Scala
object Test_MatchCaseClass {
  def main(args: Array[String]): Unit = {
    val student = Student1("aaron", 22)

    val result = student match {
      case Student1("aaron", 22) => "Aaron, 22"
      case _ => "Something Else"
    }
    println(result)
  }
}

case class Student1(val name: String, val age: Int)


--------  Output  --------
Aaron, 22
```



**特殊用法：**

1）for循环直接用模式匹配接受集合内元素，也可以自定义一些匹配的值作为筛选

2）在集合的高级计算函数中使用，只要是集合计算取单个元素的函数都可以对单个元素进行模式匹配，但在模式匹配前必须加case关键字（偏函数）。

```Scala
val list: List[List[String]] = List(
  List("a", "1", "ssss", "aaron"), 
  List("b"), 
  List("c", "3", "wwww")
)

for ("a" :: second :: rest <- list) {  // 指定List[String]第一个元素为a
	println("a" + " " + second + " " + rest)
}

println(
	list.map{
    // 若只有三个元素，则映射为一个元组  List("c","3","wwww") => ("ccc","wwww")
		case List(fir,sec,rest) => (fir*3, rest)  
		case item => item.head  // 其它情况映射List[String]的头元素
	}
)

val list2 = list.filter{
	case first::rest => first.charAt(0) < 'b'		// 根据List[String]第一个元素的第一位小于b的原则进行过滤  'a','b','c' => 'a'
}
println(list2)


--------  Output  --------
a 1 List(ssss)
List(a, b, (ccc,wwww))
List(List(a, 1, ssss))
```

上面实际上是用了 Scala 语法糖在提供给偏函数更简单的写法，原声明方式如下：

```Scala
list.map{
	t => {
    t match {
    	case List(fir,sec,rest) => (fir*3, rest)  
			case item => item.head
  	}
	}
}
```



