---
title: Scala 入门学习（三）： 函数式编程
date: 2021-08-08
tags:
 - Scala
sidebar: auto
categories:
 -  大数据
---

> 本系列文章会着重介绍Scala与Java的不同点，较适合学习过Java的人阅读。
> 
> 本篇文章介绍了Scala的函数式编程。

## Scala--函数式编程

重要！重要！重要！:arrow_up:

命令式编程 vs 函数式编程

前者对计算机友好，定义一个变量并赋值，该变量存储在计算机分配到的一段存储空间中，对变量值进行修改，计算机找到变量存储的位置，对该位置上的值进行覆盖；函数式编程对于计算机更好理解，执行效率更高。

后者函数式编程鼓励使用的是常量而不是变量，函数接收相同的输入就会返回相同的值，更符合人类数学的思想，可以在编程中专注于业务逻辑，对大数据中的并发友好，但执行效率会略微降低。

Scala中强化了**函数**的概念，函数是程序语句的集合，代码块的任何地方都可以定义函数，Java 只能作为方法定义在类中。



### 函数参数

可变参数：传入多个参数，包装成集合类；传入参数的类型必须要和函数中定义的相同，且如果参数列表中存在多个参数，可变参数一般放置在最后。

```Scala
def f1(str: String*): Unit = {
	println(str)
}

f1("aaron")
f1("aaron","wenger")


--------  Output  --------
WrappedArray(aaron)
WrappedArray(aaron, wenger)
```

参数默认值：函数的参数可以设置默认值，但有默认值的参数需要放在参数列表的最后。因为有默认值的参数可传可不传，放在第一个无法判断是否传了有默认值的参数。

带名参数：参数较多时，可以传参时根据函数名传递。这样可以不那么在意参数的顺序。

```Scala
def f2(name: String, age: Int, sex: String = "男"): Unit = {
	println(s"性别：${sex}，姓名：${name}，年龄：${age}岁")
}

f2(age = 22, name = "aaron");


--------  Output  --------
性别：男，姓名：aaron，年龄：22岁
```



### 函数至简原则

九个原则如下：

```Scala
object Test04_Simplify {
  def main(args: Array[String]): Unit = {
    def f0(name: String): String = {
      return name
    }
    println(f0("aaron"))
    println("====================")
    //    (1)return 可以省略，Scala 会使用函数体的最后一行代码作为返回值
    def f1(name: String): String = {
      name
    }
    println(f1("aaron"))
    println("====================")

    //    (2)如果函数体只有一行代码，可以省略花括号
    def f2(name: String): String = name
    println(f2("aaron"))
    println("====================")

    //    (3)返回值类型如果能够推断出来，那么可以省略(:和返回值类型一起省略)
    def f3(name: String) = name  // f(x) = x
    println(f3("aaron"))
    println("====================")

    //    (4)如果有 return，则不能省略返回值类型，必须指定
    //    (5)如果函数明确声明 Unit，那么即使函数体中使用 return 关键字也不起作用
    def f5(name: String): Unit = {
      return name
    }
    println(f5("aaron"))
    println("====================")
    
    //    (6)Scala 如果期望是无返回值类型，可以省略等号
    def f6(name: String) {
      println(name)
    }
    println(f6("aaron"))
    println("====================")
    
    //    (7)如果函数无参，但是声明了参数列表，那么调用时，小括号，可加可不加
    def f7() {
      println("aaron")
    }
    f7()
    f7
    println("====================")
    
    //    (8)如果函数没有参数列表，那么小括号可以省略，调用时小括号必须省略
    def f8 {
      println("aaron")
    }
    // f8()  // error
    f8
    println("====================")
    
    //    (9)如果不关心名称，只关心逻辑处理，那么函数名(def)可以省略
    def f9(f: String => Unit) = {
      f("aaron")
    }
    f9((x: String) => {
      println(x)
    })
  }
}
```



### 匿名函数

匿名函数是一个不用起名字的函数，形式为(x:Int)=>{函数体}，Java 8也有引入该特性；

匿名函数是不用声明返回类型的，会根据函数体的最后一行自动判断返回类型，类似普通函数只保留等号省略冒号和返回类型。

将匿名函数当作参数传给另外一个函数，可以扩展函数功能，匿名函数同样有至简原则。

```Scala
def f(func: String => Unit): Unit = { // f参数为匿名函数
	func("aaron")
}

f((name: String) => {
	println(name)
})
println("==========================")

//    (1)参数的类型可以省略，会根据形参进行自动的推导
f((name) => {
println(name)
})

//    (2)类型省略之后，发现只有一个参数，则圆括号可以省略;其他情况:没有参数和参 数超过 1 的永远不能省略圆括号。
f(name => {
println(name)
})

//    (3)匿名函数如果只有一行，则大括号也可以省略
f(name => println(name))

//    (4)如果参数只出现一次，则参数省略且后面参数可以用_代替
f(println(_))

//    (5)如果可以推断出传入的println是函数体不是调用语句，可以省略_
f(println)
```

一个匿名函数的实际应用，确定操作数1和2，通过匿名函数传对1和2的操作。下划线代替只出现一次的参数时，下划线代表的参数需要按照参数声明时的顺序，因此如果计算的是 b - a，可以改成 -a + b即 -_ + _。

```Scala
def OperationOneAndTwo(func: (Int, Int) => Int): Int = {
	func(1, 2)
}

println(OperationOneAndTwo((a: Int, b: Int)=>{a+b}))  # 3
println(OperationOneAndTwo((a: Int, b: Int)=>{a-b}))  # -1

println(OperationOneAndTwo((a, b) => a + b))	# 3
println(OperationOneAndTwo((a, b) => a - b))	# -1

println(OperationOneAndTwo(_ + _))	# 3
println(OperationOneAndTwo(_ - _))	# -1

println(OperationOneAndTwo((a, b) => b - a))  # 1
println(OperationOneAndTwo(-_ + _))  #1
```



### 函数高阶应用：函数作为值传递

两种传递方法：

- 声明变量的类型为函数（需要有输入参数和返回类型）
- 直接赋值函数名加空格加下划线，表示函数整体

```scala
def f(n: Int): Int = {
println("f调用")
	n + 1
}

def fun(): Int = {
	println("func调用")
	1
}
val result = f(123)
println(result)

// 方法一
val f1: Int => Int = f
// 方法二
val f2 = f _  
println(f1(10))
println(f2(30))

// 无参函数
println(fun)
val f3: () => Int = fun  // 写 Unit => Int 报错
val f4 = fun _
println(f3)
println(f4)


--------  Output  --------
f调用
124
f调用
11
f调用
31
func调用
1
chapter05.Test06_HighOrderFunc$$$Lambda$7/41903949@48140564
chapter05.Test06_HighOrderFunc$$$Lambda$8/488970385@58ceff1
```



### 函数高阶应用：函数作为参数传递

匿名函数中已经有过介绍，直接看例子：

```Scala
def Dual(op:(Int, Int)=>Int, a:Int, b: Int): Int = {
	op(a, b)
}

println(Dual((a, b) => a+b, 11, 4))
println(Dual(_+_, 11, 4))


--------  Output  --------
15
15
```



### 函数高阶应用：函数作为函数的返回

```Scala
def f5() = {
	def f6(a: Int): Unit = {
  	println("f6调用" + a)
  }
	f6 _
}

/* OR
def f5(): Int => Unit = {
  	def f6(a: Int): Unit = {
  	println("f6调用" + a)
	}
  f6
}
*/

f5()(16)


--------  Output  --------
f6调用16
```



### 闭包

首先看这样一个Scala函数的高阶应用：

定义一个函数 func，它接收一个 Int 类型的参数，返回一个函数(记作 f1)。 它返回的函数 f1，接收一个 String 类型的参数，同样返回一个函数(记作 f2)。函数 f2 接 收一个 Char 类型的参数，返回一个 Boolean 的值。

```Scala
def func(a: Int): String => (Char => Boolean) = {
  def func1(b: String): Char => Boolean = {
  	def func2(c: Char): Boolean = {
  		if( a == 0 && b == "" && c == '0') false else true
		}
  	func2
	}
  func1
}

// 简化
def func_simplify(a: Int): String => (Char => Boolean) = {
	b => c => if( a == 0 && b == "" && c == '0') false else true
}

println(func(0)("")('0'))
println(func_simplify(0)("")('0'))


--------  Output  --------
false
false
```

上面两个函数都正确的完成了任务，乍一看会发现问题，func2 作为最内层的函数调用了外层的a和b，然而在 func2 执行时候 func 和 func1 已经执行完毕；在 Java 的概念中，方法执行时，局部变量都保存在JVM的栈空间中，执行结束释放栈空间；Scala由于进一步强化了面对对象的思想，每一个函数底层都是一个对象实例，对象的空间同 Java 一样保存在堆中，堆空间的释放由GC机制（垃圾回收）决定。

在这里引入**闭包**的概念：如果一个函数，访问到了它的外部(局部)变量的值，那么这个函数和他所处的环境，称为闭包。

因此 func1 对象的闭包中已经有了 func 中的变量a，func2 同理。



### 函数柯里化

闭包可以用柯里化来表达，柯里化底层一定包含着一个闭包。

函数柯里化：把一个参数列表的多个参数，变成多个参数列表。

```Scala
// 上面闭包例子改成柯里化
def func(a: Int)(b: String)(c: Char): Boolean = {
	if( a == 0 && b == "" && c == '0') false else true
}

println(func(0)("")('0'))

print("=======")

def addByCurry(a: Int)(b: Int): Int => Int = a + b + _

val addFour1 = addByCurry(4)(5)
val addFive1 = addByCurry(5)(10)
println(addFour1(10))
println(addFive1(10))


--------  Output  --------
false
=======
19
25
```

闭包和柯里化的好处可能通过这么几个小例子很难体现出来，日后学习Spark时会再做补充。



### 控制抽象

传值参数：把计算后的值传递过去

传名参数：传递可执行代码块，函数中只要出现一次传名参数就执行一遍该代码块

```Scala
def f1(): Int = {
  println("f1调用")
  12
}

// 传名参数，传递代码块
def f2(a: =>Int) = {
  println("a: " + a)
  println("a: " + a)
}

f2(f1())


--------  Output  --------
f1调用
a: 12
f1调用
a: 12
```



### 惰性计算

体现为懒加载，lazy关键字实现；函数计算结果赋值的变量前如果声明了lazy关键字，当下面使用到该变量时才会进行函数的计算，因此看到了下面1和2的顺序颠倒。

```Scala
def sum(a: Int, b: Int) = {
	println("1. 计算求和")
	a + b
}

lazy val res: Int = sum(11, 4)

println("2. sum函数应该调用过了吧")
println("3. 输出结果 res = " + res)


--------  Output  --------
2. sum函数应该调用过了吧
1. 计算求和
3. 输出结果 res = 15
```



**函数式编程应用：实现while循环**

```Scala
object Test_MyWhile {
  def main(args: Array[String]): Unit = {

    // 闭包 + 匿名函数 + 递归
    def myWhile(condition: =>Boolean): (=>Unit) => Unit = {
        op => if(condition) {
          op
          myWhile(condition)(op)
        }
    }

    // 柯里化形式
    def myWhile1(condition: =>Boolean)(op: =>Unit): Unit = {
      if(condition) {
        op
        myWhile1(condition)(op)
      }
    }

    var n = 5
    myWhile( n>0 )({
      println(n)
      n -= 1
    })

    println("============")

    n = 5
    myWhile1( n>0 )({
      println(n)
      n -= 1
    })
  }
}


--------  Output  --------
5
4
3
2
1
============
5
4
3
2
1
```

