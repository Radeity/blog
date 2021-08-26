---
title: Scala 入门学习（四）： 面向对象
date: 2021-08-10
tags:
 - Scala
sidebar: auto
categories:
 -  大数据
---

> 本系列文章会着重介绍Scala与Java的不同点，较适合学习过Java的人阅读。
> 
> 本篇文章介绍了Scala的面向对象思想。

## Scala 面向对象

面向对象是Scala另一大重要思想，值得学习。



### 包

Scala中包名和源文件路径不要求一致，它只代表了逻辑上的层级关系，非物理存储上。

**嵌套风格**

表示包层级关系时，Scala提供了另外一种嵌套的风格，嵌套风格声明包如下：

```Scala
// 嵌套风格
package com {

  import com.shanghai.scala1.Inner1

  // 外层包中单例对象
  object Outer {
    var name = "aaron"
    def main(args: Array[String]): Unit = {
      println(Inner1.in)
    }
  }

  package shanghai {
    package scala1 {

      import com.beijing.scala2.Inner2

      // 内层包中定义单例对象
      object Inner1 {
        var in: String = "in"
        def main(args: Array[String]): Unit = {
          println(Outer.name)
          Outer.name = "Ramsey"
          println(Outer.name)
          Inner2.main()
        }
      }
    }
  }
}

package com {
  package beijing {
    package scala2 {
      object Inner2 {
        def main(): Unit = {
          println(Outer.name)
          Outer.name = "Wenger"
          println(Outer.name)
        }
      }
    }
  }
}



--------  Output  --------
aaron
Ramsey
Ramsey
Wenger
```

内层包可以直接访问外层包的属性和方法，访问时要加外层包的object名称；外层包访问内层包时则必须import。同一个文件内可以定义多个包，可以看到由于在程序中第一个嵌套包com.shanghai.scala1声明时，已经在外层包com中定义了单例对象Outer，因此第二个嵌套包com.beijing.scala2内层对象也可以直接调用Outer中的属性。



**包对象**

Scala中可以定义与包同名的包对象，定义在包对象中的成员，作为其对应包下所有 class 和 object 的共享变量，可以被直接访问。与上面访问外层包中object成员区别就在不用加Object名称，可以直接通过变量名访问。

```Scala
package com {

  package shanghai {
    package scala1 {

      import com.beijing.scala2.Inner2

      // 内层包中定义单例对象
      object Inner1 {
        var in: String = "in"
        def main(args: Array[String]): Unit = {
          println(out)
          out = "outer"
          println(out)
         	func(in)
          Inner2.main()
        }
      }
    }
  }
}

package com {
  package beijing {
    package scala2 {
      object Inner2 {
        def main(): Unit = {
          println(out)
	        out = "outerrrrrrr"
          println(out)
        }
      }
    }
  }
}

package object com {
  var out: String = "out"
  def func(str: String): Unit = {
    println(str)
  }
}


--------  Output  --------
out
outer
in
outer
outerrrrrrr
```

包对象中定义的属性如果希望包中可以访问到，需要在同一层级（作用域）下，比如：要在上面程序中定义shanghai的包对象，那该包对象也得在com包下。



**导包**

Scala中导包可以局部导入，局部导入的包只在当前上下文有效。

Scala中通配符是下划线 _ ，不同于Java的 *。

Scala给类起名：import java.util.{ArrayList=>AL}

导入**相同包的**多个类：import java.util.{HashSet, ArrayList}

屏蔽类:import java.util.{ArrayList =>_ , _ }，将ArrayList屏蔽，导入其它所有。

Scala 中还有三个默认导入分别是：

**import java.lang._ import scala._ import scala.Predef._**

比如常用的println就在Predef._中。



### 类和对象

Scala一个文件可以定义多个class或object；

Scala中不提供访问控制修饰符public，什么也不加默认为public；

类中属性赋默认初始值可以用下划线；

@BeanProperty注解会自动创建符合 JavaBean 规范的getter、setter，

```Scala
import scala.beans.BeanProperty

object Test03_Class {
  def main(args: Array[String]): Unit = {
    val student = new Student()
    println(student.getName())
    println(student.getAge)
    student.setName("aaron")
    println(s"姓名：${student.getName()}  年龄：${student.getAge}")
  }
}

class Student {

  private var name: String = _
  @BeanProperty
  var age: Int = 22
  var sex: String = "Male"
  def getName(): String = {
    name
  }
  def setName(name: String): Unit = {
    this.name = name
  }
}


--------  Output  --------
null
22
姓名：aaron  年龄：22
```



**封装**

封装的概念应该都不陌生，将数据封装起来通过指定方法去访问。Scala提供进一步的封装，“public”属性底层实际上都是private，访问时会调用get和set方法，但这里的方法名并不是getXXX和setXXX，由于一些Java框架会利用反射调用getXXX和setXXX，因此Scala也提供了上面提到过的@BeanProperty注解去生成某属性的这两个方法，但注意@BeanProperty不能加在private修饰的属性上，可以理解为由于“public”本身就是private，将变量修饰为private然后再提供getter、setter方法比较冗余，Scala不推荐这样做。



**访问权限**

- Scala 中属性和方法的默认访问权限为 public，但 Scala 中无 public 关键字。
- private 为私有权限，只在类的内部和伴生对象中可用。
- protected 为受保护权限，Scala 中受保护权限比 Java 中更严格，同类、子类可以访问，同包无法访问。
- private[包名]增加包访问权限，包名下的其他类也可以使用

```Scala
class Person {
  private var id: String = "252257465"
  protected var name: String = "aaron"
  var sex: String = "female"
  private[chapter06] var age: Int = 22

  def printInfo: Unit = {
    println(s"Person: $id $name $sex $age")
  }
}

class Worker extends Person {
  override def printInfo: Unit = {
    name = "season"
    sex = "male"
    age = 20
    //    id = "21223412"  // error
    println(s"Worker: $name $sex $age")

  }
}

object Test_Access {
  def main(args: Array[String]): Unit = {
    val person = new Person
    println(person.age)
    println(person.sex)
    //    print(person.name)  // error
    //    print(person.id)  // error
    person.printInfo
    val worker = new Worker
    worker.printInfo

  }
}


--------  Output  --------
22
female
Person: 252257465 aaron female 22
Worker: season male 20
```



**构造器**

Scala中定义类可以理解为也是一个函数，此函数是这个类的**主构造器**（主构造方法），可以在类名后加括号和传入主构造器的参数，同其它函数一样，若没有参数括号可以省略。在类中定义名为this的带参函数即为**辅助构造器**（辅助构造方法），可以重载为多个，需要注意，辅助构造器不能直接构建对象，必须直接或者间接调用主构造器，且必须在首行。Java中与类名相同的方法在Scala的类中只是一个普通函数。

```Scala
object Test05_Constructor {
  def main(args: Array[String]): Unit = {
    val student1 = new Student1()
    val student2 = new Student1("aaron")
    val student3 = new Student1("aaron",22)
  }
}

class Student1() {
  var name: String = _
  var age: Int = _
  println("主构造器被调用")

  def this(name: String) {
    this()
    println("辅助构造器1被调用")
    this.name = name
    println(s"name: $name, age: $age")
  }

  def this(name: String, age: Int) {
    this(name)
    println("辅助构造器2被调用")
    this.age = age
    println(s"name: $name, age: $age")
  }
}


--------  Output  --------
主构造器被调用
主构造器被调用
辅助构造器1被调用
name: aaron, age: 0
主构造器被调用
辅助构造器1被调用
name: aaron, age: 0
辅助构造器2被调用
name: aaron, age: 22
```

Scala 类的主构造器函数的形参包括三种类型

- 未用任何修饰符修饰，这个参数就是一个局部变量
- var 修饰参数，作为类的成员属性使用，可以修改 
- val 修饰参数，作为类只读属性使用，不能修改

```Scala
object Test_ConstructorParam {
  def main(args: Array[String]): Unit = {
    val student2 = new student2("aaron", 22)
    println(s"name: ${student2.name}, age: ${student2.age}")  // 成员变量可直接访问

    val student3 = new student3("ramsey", 28)
    student3.printInfo()
    // println(s"name: ${student3.name}, age: ${student3.age}")  // error 局部变量无法直接访问
  }
}

class student2 (var name: String, var age: Int)

class student3 (name: String, age: Int) {
  def printInfo(): Unit = {
    println(s"name: ${name}, age: ${age}")
  }
}


--------  Output  --------
name: aaron, age: 22
name: ramsey, age: 28
```



**继承**

先给出代码

```Scala
object Test07_Inherit {
  def main(args: Array[String]): Unit = {
    val student = new Student("aaron", 22, "171717")
    student.printInfo()
  }
}

class Person {
  var name: String = _
  var age: Int = _
  println("1 父类主构造器被调用")

  def this(name: String, age: Int) {
    this()
    println("2 父类辅助构造器被调用")
    this.age = age
    this.name = name
  }

  def printInfo(): Unit = {
    println(s"name: $name, age: $age")
  }
}

class Student(_name: String, _age: Int) extends Person { //(name, age) {
  var stuNo: String = _
  println("3 子类主构造器被调用")

  def this(name: String, age: Int, stuNo: String) {
    this(name, age)
    println("4 子类辅助构造器被调用")
    this.stuNo = stuNo
  }

  override def printInfo(): Unit = {
    println(s"Student[name: ${name}, age: ${age}, stuNo: ${stuNo}]")
  }
}


--------  Output  --------
1 父类主构造器被调用
3 子类主构造器被调用
4 子类辅助构造器被调用
Student[name: null, age: 0, stuNo: 171717]
```

Student类继承Person类，Scala中继承要声明是继承的父类哪一个构造器，上面的extend Person实则是省略了Person后的括号，继承Person的主构造器，Student类主构造器传的参数是局部变量，因为会继承父类的属性name和age，没必要再声明为子类的属性；继承的调用顺序是父类构造器先于子类构造器，上面的程序会先调用继承的父类构造器Person()，再通过this(name, age)调用子类的主构造器，然后最后是子类辅助构造器；由于是调用的父类主构造器，并没有对继承的属性name和age赋值，只在子类构造器中修改了成员属性stuNo，因此得到了上面的输出结果。

如果将 extend Person 改为 extend Person ( _name, _age)，输出结果如下：

```Scala
--------  Output  --------
1 父类主构造器被调用
2 父类辅助构造器被调用
3 子类主构造器被调用
4 子类辅助构造器被调用
Student[name: aaron, age: 22, stuNo: 171717]
```

继承的是父类的辅助构造器，因此会调用继承的父类构造器对name和age进行了赋值后再调用子类构造器，输出查看也都是三个属性赋值后的结果。



**多态**

Scala 中属性和方法都是动态绑定，而 Java 中只有方法为动态绑定。

先看一下Java中的多态：

```Java
class Person {
    int age = 20;
    public void printInfo() {
        System.out.println("Person");
    }
}
class Student extends Person {
    int age = 22;
    public void printInfo() {
        System.out.println("Student");
    }
}

class Test {
    public static void main(String args[]) {
        Person p = new Student();
        System.out.println(p.age);
        p.printInfo();
    }
}


--------  Output  --------
20
Student
```

p是Person类型的引用，当前语句是指向了new出来的一个Student对象，但它在后面仍然可以指向一个Person对象，编译时就会将p和Person绑定在一起，p的age属性是静态绑定的所以值为20。printInfo则为动态绑定，程序最终执行的是实际类型Student的printInfo。

Java的属性静态绑定是为了在编译期就能发现一些错误，Scala的理念中基本去除了所有静态的概念，所以属性和方法都为动态绑定。

```Scala
object Test_DynamicBind {
  def main(args: Array[String]): Unit = {
    val student: Person8 = new Student8
    println(student.name)
    student.hello
  }
}

class Person8 {
  val name: String = "person"
  def hello = {
    println("hello person")
  }
}

class Student8 extends Person8 {
  override val name: String = "student"
  override def hello: Unit = {
    println("hello student")
  }
}


--------  Output  --------
student
hello student
```



**抽象类**

- 抽象类：abstract class Person {...}  抽象类内也可以没有抽象属性抽象方法
- 抽象属性：val|var name:String  没有初始化的属性即为抽象属性
- 抽象方法：def printInfo():String  只有声明没有实现即为抽象方法

子类重写非抽象属性或方法需要加override，实现抽象属性或方法不需要加 override。

子类重写非抽象属性只支持val类型，var修饰可变变量直接赋值即可。

子类不实现所有抽象属性和方法仍需声明为抽象类。

抽象类还可以声明匿名子类，实现方法如下：

```Scala
object Test_AnonymousClass {
  def main(args: Array[String]): Unit = {
    val person: Person = new Person {
      override var name: String = "aaron"
      override def hello(): Unit = println(s"hello $name")
    }

    println(person.name)
    person.hello()
  }
}

abstract class Person {
  var name: String
  def hello(): Unit
}


--------  Output  --------
aaron
hello aaron
```



**单例对象（伴生对象）**

伴生对象和伴生类相伴相生，Scala去除了static关键字，在伴生对象内保存一些“静态”的属性和方法，这些静态的内容可以在任何地方前面加上类名调用，伴生对象内也可以访问伴生类的全部成员（包括private）；这些静态内容拥有了所属的对象（伴生对象），更符合面向对象的思想。

伴生对象和伴生类名称必须相同，且放在同一个文件中

前面在测试时广泛使用了伴生对象，因为main函数也是只需要一份的，放到伴生对象中可以直接检测到并执行。

伴生对象提供了一个特殊的apply方法，apply方法中new了一个伴生类的实例化对象，调用apply方法时可以省略apply，写法比较简洁；apply方法可以重载。

```Scala
object Test_Object {
  def main(args: Array[String]): Unit = {

//    val stu = new Student("aaron", 22)  // Student主构造器不用private修饰可以使用
//    stu.printerInfo()

    val stu1 = Student.newStudent("aaron", 22)
    stu1.printerInfo()

    val stu2 = Student("aaron", 22)
    stu2.printerInfo()

    val stu3 = Student("aaron")
    stu3.printerInfo()
  }
}

class Student private(val name: String, val age: Int) {
  def printerInfo(): Unit = {
    println(s"name: $name, age: $age, school: ${Student.school}")
  }
}

object Student {
  val school: String = "uuu"
  def newStudent(name: String, age: Int): Student = {
    new Student(name, age)
  }

  def apply(name: String, age: Int): Student = new Student(name, age)

  def apply(name: String): Student = new Student(name, 0)
}
```

伴生对象实现单例设计模式

```scala
object Test_Single {
  def main(args: Array[String]): Unit = {
    val stu1 = Student.getInstance()
    val stu2 = Student.getInstance()

    stu1.printerInfo()
    stu2.printerInfo()

    println(stu1)  // 输出引用
    println(stu2)
  }
}

class Student private(val name: String, val age: Int) {
  def printerInfo(): Unit = {
    println(s"name: $name, age: $age, school: ${Student.school}")
  }
}


object Student {
  val school: String = "uuu"
  private var student: Student = null
  def getInstance(): Student = {
    if (student == null) {
      student = new Student("aaron", 22)
    }
    student
  }
}


--------  Output  --------
name: aaron, age: 22, school: uuu
name: aaron, age: 22, school: uuu
chapter06.Student12@129a8472
chapter06.Student12@129a8472
```



### 特质 (Trait)

Scala中用Trait代替了Java中的interface，可以有抽象和非抽象方法；抽象类只能单继承，特质可以多“实现”，称作特质的混入（mixin），整体类别有从属关系时用抽象类，附加某种方法时用特质，更加灵活。如果需要有参构造时只能用抽象类。

使用特质的例子：

```Scala
object Test_Trait {
  def main(args: Array[String]): Unit = {
    val student1 = new Student
    student1.sayHello()  // 重写抽象类中的非抽象方法
    student1.dating()  //实现Young特质中的抽象方法
    student1.play()  // 引入Young特质的方法
    student1.study() // Student类自己的方法
  }
}

class Person {
  val name: String = "person"
  val age: Int = 22
  def sayHello(): Unit = {
    println("hello from: " + name)
  }
}

trait Young {
  val age: Int
  val name: String = "young"

  def play() = {
    println("young people is playing")
  }
  def dating(): Unit
}

class Student extends Person with Young {
  override val name: String = "stu"
  def dating(): Unit = println(s"student $name is dating")
  def study() = println(s"student $name is studying")

  override def sayHello(): Unit = {
    super.sayHello()
    println(s"hello from student $name")
  }
}


--------  Output  --------
hello from: stu
hello from student stu
student stu is dating
young people is playing
student stu is studying
```

上面的代码中声明Student时继承了父类Person并引入了特征Young，若只引入特征则写为 **class Student extends Young**；另外需要注意，name属性由于特质和抽象类中都定义为是一个非抽象属性，因此在Student类中需要重写，否则不知道应该用哪一个；age属性特质中定义为抽象属性，抽象类中定义为非抽象属性，因此可以直接使用。

特质混入的声明在一个特质后叠加 with 特质名即可，例：class Student extends Person with Young with... 混入多个特质同样要保证冲突的属性或方法需要重写，抽象的属性或方法要实现。

特质的 **动态混入** 是在实例化时引入新特质，同样需要对冲突和抽象的内容进行处理。例子如下：

```Scala
object Test_Trait {
  def main(args: Array[String]): Unit = {
    val student1 = new Student with Talent {
      def singing(): Unit = println(s"student $name is singing")
      def dancing(): Unit = println(s"student $name is dancing")
    }
    student1.dating()
    student1.increase()
    student1.play()
    student1.increase()
    student1.study()
    student1.increase()
    student1.singing()
    student1.increase()
    student1.dancing()
    student1.increase()
  }
}

class Person {
  val name: String = "person"
  val age: Int = 22
  def sayHello(): Unit = {
    println("hello from: " + name)
  }
}

trait Young {
  val age: Int
  val name: String = "young"
  def play(): Unit = {
    println("young people is playing")
  }
  def dating(): Unit
}

trait Knowledge {
  var amount: Int = 0
  def increase(): Unit
}

trait Talent {
  def singing()
  def dancing()
}

class Student extends Person with Young with Knowledge {

  override val name: String = "stu"
  def dating(): Unit = println(s"student $name is dating")
  def study(): Unit = println(s"student $name is studying")
  
  override def sayHello(): Unit = {
    super.sayHello()
    println(s"hello from student $name")
  }
  
  def increase(): Unit = {
    amount += 1
    println(s"student ${name} knowledge increased: ${amount}")
  }
}


--------  Output  --------
student stu is dating
student stu knowledge increased: 1
young people is playing
student stu knowledge increased: 2
student stu is studying
student stu knowledge increased: 3
student stu is singing
student stu knowledge increased: 4
student stu is dancing
student stu knowledge increased: 5
```

特征叠加时，若有方法的冲突，我们在重写的该方法中使用super默认调用的是叠加的最后一个（最右边）特征的方法，下面钻石问题中有解释；上面例子中假设Person、Young、Knowledge都有printInfo方法，Student类override的printInfo方法中执行super.printInfo会执行Knowledge的printInfo方法。

钻石问题的特质叠加见下图：（下面例子中每个特质都有describe方法）

![image-20210813132959242](/Users/wangweirao/Library/Application Support/typora-user-images/image-20210813132959242.png)

- 案例中的 super，不是表示其父特质对象，而是表示上述叠加顺序中的下一个特质， 即，**MyClass** **中的** **super** **指代** **Color**，**Color** **中的** **super** **指代** **Category**，**Category** **中的** **super** **指代** **Ball**。
- 如果想要调用某个指定的混入特质中的方法，可以增加约束:super[]，例如super[Category].describe()。



### 扩展

**自身类型**

Scala的自身类型也是一个比较独特的引入，它声明当前特质或类本身真正属于什么类型，实现依赖注入的功能；例子可以参考这篇博客：https://blog.csdn.net/kypfos/article/details/79324088。



**类型检查和转换**

- obj.isInstanceOf[T]:判断 obj 是不是 T 类型。

- obj.asInstanceOf[T]:将 obj 强转成 T 类型。
- classOf 获取对象的类名。

重温一个Java的知识点：

父类引用可以指向子类对象，该引用可以使用子类继承和重写的方法；

子类引用不可以指向父类对象，否则引用中的一些子类独有方法在指向对象中找不到具体实现。



**枚举类和应用类**

枚举类概念一定不陌生了，应用类就是继承App，不用写main方法可以直接执行，直接看代码：

```Scala
object WorkDay extends Enumeration {
  val Key = Value(1, "dasd12eas213j1d")
  val Token = Value(2, "12345678909876543")
}

object TestApp extends App {
  println("APP START")
  println(WorkDay.Key)
  println(WorkDay.Token)
}


--------  Output  --------
APP START
dasd12eas213j1d
12345678909876543
```

