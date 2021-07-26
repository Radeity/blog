---
title: NOTE—CSAPP（个人理解）
date: 2020-11-01
tags:
 - CSAPP
sidebar: auto
categories:
 -  计算机基础
---
*深入理解计算机系统（第二版）*
[[toc]]


## 第4章：处理器体系结构

1. （P-248）**易混淆概念：程序寄存器←→硬件寄存器**

    程序寄存器：CPU中为数不多可寻址的字，通常存在寄存器文件中，寻址寄存器文件获取寄存器存取内容。

    硬件寄存器：当时钟信号处于高频上升阶段时，才将输入的信号加载，例如（PC,CC,STAT）。

2. （P-260）**Y86实现的一个重要原则：处理器从来不需要为了完成一条指令的执行而去读由该指令更新了的状态。**

    pushl指令中把更新栈指针放最后就是因为这个原则，有了这个原则，访存和写回可以在同一个时钟信号的控制下同时进行，效率提升。

3. （P-273）**SEQ+中把更新PC操作放到新的周期开始时，上一个周期执行后PC应有的变化存到一系列状态寄存器中，这样就不需要在一个周期结束时再通过时钟上升去改变PC寄存器的值。（tips：SEQ+无程序计数器**
4. （P-276）在SEQ+中，在译码阶段通过逻辑电路计算得到dstE和dstM，会直接将其连接到寄存器文件的写端口的地址输入，当计算出valE和valM时直接写回到对应寄存器中。但是dstE和dstM是在译码阶段计算出来的，而valE是在执行阶段计算得到，valM是在访存阶段获得的，在流水线系统PIPE-中各个阶段是相互独立的，当某

    条指令运行到写回阶段时，得到了valE和valM，但是当前的dstE和dstM是处于译码阶段的指令计算出来的，会出现错误，所以需要将dstE和dstM一直保存到后续的流水线寄存器中。通用规则：我们要保存处于一个流水线阶段中的指令的所有信息。 *—-from [知乎](https://zhuanlan.zhihu.com/p/107760564)*

    个人补充：valM和valE不是每次一定都会在写回的时候写入寄存器，（如：sub操作写valE，ret操作valE和valM都写，详情见图4.18至图4.21），但为了用统一的硬件结构，需要将desE和desM在流水线寄存器中进行传递。

5. 转发来避免数据冒险时五个不同的转发源。*—-from [知乎](https://zhuanlan.zhihu.com/p/107760564)*
    - `e_valE`：在执行阶段，ALU中计算得到的结果`valE`，通过`E_dstE`与`d_srcA`和`d_src_B`进行比较决定是否转发。
    - `M_valE`：将ALU计算的结果`valE`保存到流水线寄存器M中，通过`M_dstE`与`d_srcA`和`d_src_B`进行比较决定是否转发
    - `m_valM`：在访存阶段，从内存中读取的值`valM`，通过`M_dstM`与`d_srcA`和`d_src_B`进行比较决定是否转发。
    - `W_valM`：将内存中的值`valM`保存到流水线寄存器W中，通过`W_dstM`与`d_srcA`和`d_src_B`进行比较决定是否转发。
    - `W_valE` ：将ALU计算的结果`valE`保存到流水线寄存器W中，通过`W_dstE`与`d_srcA`和`d_src_B`进行比较决定是否转发。
6. （P-288）加载/使用数据冒险：0x018的指令为mrmovl D(rB),rA是将寄存器rB加偏移的内存地址中的值存到寄存器rA中，访存阶段才能获取rB+C（偏移）的值，所以不同于"#prog4"中irmovl可以从上一条指令执行阶段直接获取所需的寄存器的值。
7. （P-287）图4-52为PIPE的硬件结构，应该吃透此图。
8. 对气泡的理解：气泡等价于用nop指令覆盖当前状态，在指定阶段加入气泡的话寄存器中的值也都会被覆盖，因此在图prog8（P-298）中分别在执行和译码阶段插入气泡相当于取消了两条irmovl指令的运行；而prog4（P-284）的<font color="orange">**区别**</font>是使用气泡来实现暂停，nop执行完之后会回到原来应该执行的阶段继续执行。

    所插入气泡的阶段从流程图上可以更直观的看出，是为了每个周期所有阶段完整。

    流水线暂停和气泡的控制逻辑的组合动作可见图4-66。（P301）

---

## 第5章：优化程序性能

1. （P-326）限制优化因素：编译器不会判断两个指针是否指向同一个位置也不会判断一个函数调用是否有副作用因此上述两种情况下编译器不会进行优化。
2. （P-337）消除不必要的存储器引用：combine3中每次都要对dest指针所指向的内存地址进行读写，但如果改为combine4，函数中的局部变量数目少于寄存器数目时，就会将局部变量保存到寄存器中，就无须在内存中进行读写了，每次寄存器取acc累乘速度快很多。
3. （P-340）现代处理器为<font color="orange">**超标量**</font>结构，有多个功能单元使得每个时钟周期执行多个操作且为乱序的，硬件结构更复杂但指令并行度更高。
4. 延迟是指执行一个操作所需的时钟周期，但是由于功能单元存在流水线，所以可以每个时钟周期都开始一个操作。只有当两个操作之间存在数据相关时，无法使用流水线了，才考虑操作的延迟。
5. （P-349）**循环展开**：只缩短了整数加法的延迟界限而没有缩短其它，因为整数加法这个指令本身延迟界限是1个时钟周期，优化前代码性能限制受循环技术的开销比较大，但其它操作因为仍然存在路径上的顺序依赖，因此无法低于指令本身的<font color="orange">延迟界限</font>。 ⭐

    总结：延迟展开可以减少迭代次数，使得不必要的操作数量减少（关键路径操作减少），但是没有解决数据相关问题，无法突破延迟界限。

6. （P-352）**使用多个累计变量多路并行**：使用不同的功能单元，或利用功能单元的流水线进行并行计算，就能突破延迟界限，但不会突破吞吐量界限（硬件决定）。使用kxk循环展开时，我们需要申请k个局部变量来保存中间结果，如果k大于寄存器的数目，则中间结果就会保存到内存的堆栈中，使得计算中间结果要反复读写内存，造成性能损失。
7. （P-356）**重新结合变换：**

    ```c
    for (i = 0; i < limit; i+=2) {
    		acc = (acc OP data[i]) OP data[i+1];
    }

    /* 移动括号位置优化上面循环 */
    for (i = 0; i < limit; i+=2) {
    		acc = acc OP (data[i] OP data[i+1]);
    }
    ```

    优化后的代码降低延迟界限的原因是每个循环的关键路径从两次mul变为了一次mul，因为只有第二个涉及到%xmml寄存器的mul操作形成循环寄存器间的数据相关链，第一次mul中数组两元素的累积不需要等前一次迭代完成就可以执行。⭐

---

## 第6+9章：存储器层次结构+虚拟存储器

1. 计算机系统中的缓存：

    ![cache](../../.vuepress/public/Untitled.png)

2. Cache地址映射：

    CPU要读取数据得到的待读取数据在主存中的地址，要映射到Cache中地址并判断是否命中，命中则在Cache中对应的Cache地址中读取。

3. Cache基本原理：[https://zhuanlan.zhihu.com/p/102293437](https://zhuanlan.zhihu.com/p/102293437)  ⭐
4. Cache相关：
    - 相联度大的缺点：每次需要比较多个cacheline，硬件可能并行比较增加比较速度，增加了硬件设计复杂度和硬件成本。
    - 一般说的cache size是64K的是可以缓存的数据的大小；都是缓存数据的，tag是单独的，程序员看不见。
    - 高速缓存越向下越可能用写回，因为越向下读写速度差距越大，用写会数据传送少。
5. 虚拟内存：[https://draveness.me/whys-the-design-os-virtual-memory/](https://draveness.me/whys-the-design-os-virtual-memory/)
6. 页表与MMU：[https://www.jianshu.com/p/046f5ea45acd](https://www.jianshu.com/p/046f5ea45acd)
7. TLB：[https://zhuanlan.zhihu.com/p/108425561](https://zhuanlan.zhihu.com/p/108425561)
8. 地址翻译：
    - 通过MMU确认的PTBR（页表基址寄存器）作为PTEA（页表条目地址）。高速缓存中找页号为VPN（虚拟页号）对应的PTE（页表条目），未找到则继续从内存中找，然后将找到的PTE返回给MMU，加上虚拟地址中的VPO（虚拟页面偏移）则为最终的物理地址，至此，完成地址翻译。（P544）
    - 结合高速缓存和虚拟存储器的思想，仍然用物理寻址，地址翻译发生在查高速缓存前。即PTE同其它数据字一样可以缓存在L1高速缓存中。
    - TLB与上面不同的是上面所讲都是要查页表来获取物理地址，然而TLB是虚拟地址和物理地址直接对应的一个缓存。由于TLB是虚拟地址，会导致不同进程可能有相同的虚拟地址但TLB中查询到的物理地址相同发生错误，因此进程切换的时候TLB整个全部无效。（P545）
9. 存储器按行寻址概念理解：如果一行有8字节，则只需要用3位来表示字节的偏移，即“101”则表示该行第5个字节。
10. 存储器映射：是磁盘中区域（非内存）和虚拟存储器区域的映射。如果虚拟存储器系统可以集成到传统的文件系统中，那么就能提供一种简单而高效的把程序和数据加载到存储器中的方法。（体现于共享对象）（P556）
    - 共享对象：即使对象被映射到了多个共享区域，物理存储器（内存）也只要放共享对象的一个copy。
    - 私有对象写时拷贝：同样在内存只放一个拷贝，且私有区域条目都设为只读，如果一个进程视图写私有区域的某个页面，则触发保护机制，在内存中创建这个页面的拷贝，更新页表条目指向这个拷贝的页面并且可正常读写。
11. 动态存储器分配
    - 隐式空闲链表：有一个头部编码了块大小以及是否分配的标志位信息，需要特殊标记的结束块。通过头部大小字段隐含着连接所以叫做隐式空闲链表。（P565）
    - 请求不到合适块的时候需要进行合并，合并有两种方式，立即合并和推迟合并；立即合并指有新的空闲块就合并，推迟合并指出现无法分配的时候合并。
    - 边界标记的合并：为了能合并上一个块而产生的方法。每个块尾添加脚部，脚部是头部的副本，上一个块的脚部是在距当前块开始位置一个字的距离。<font color="orange">缺点：</font>虚拟存储器有很多个小块因为每个块要同时维护一个头部和脚部，产生很多开销。优化：只会在空闲块上进行合并，所以在已分配的块上可以不需要脚部，空闲块要判断前一个块是否为已分配可以在自己的头部的3个位中用一个位来标记前一个块是否为空闲的，如果前一个块为已分配的，则无需关心前一个块的大小，因为不会进行合并；如果前一个块为空闲的，则前一个块自己就有脚部，说明了前一个块的大小，则可以顺利进行合并操作。ps:空闲块仍需要脚部。
12. 进程虚拟地址空间与虚拟存储空间：[https://blog.csdn.net/tennysonsky/article/details/45092229](https://blog.csdn.net/tennysonsky/article/details/45092229)
13. 提高存储器性能主要从存储器速度和容量出发，cache提高速度，虚拟内存提高容量。⭐

---

## 第others章

1. 并发编程模式：

    下面举一个例子，模拟一个tcp服务器处理30个客户socket。假设你是一个老师，让30个学生解答一道题目，然后检查学生做的是否正确，你有下面几个选择：

    （1） 第一种选择：**按顺序逐个检查**，先检查A，然后是B，之后是C、D。。。这中间如果有一个学生卡主，全班都会被耽误。

    这种模式就好比，你用循环挨个处理socket，根本不具有并发能力。

    （2）第二种选择：你**创建30个分身**，每个分身检查一个学生的答案是否正确。 这种类似于为每一个用户创建一个进程或者线程处理连接。

    （3）第三种选择，你**站在讲台上等，谁解答完谁举手**。这时C、D举手，表示他们解答问题完毕，你下去依次检查C、D的答案，然后继续回到讲台上等。此时E、A又举手，然后去处理E和A。。。这种就是IO复用模型，Linux下的select、poll和epoll就是干这个的。将用户socket对应的fd注册进epoll，然后epoll帮你监听哪些socket上有消息到达，这样就避免了大量的无用操作。此时的socket应该采用**非阻塞模式**。

    这样，整个过程只在调用select、poll、epoll这些调用的时候才会阻塞，收发客户消息是不会阻塞的，整个进程或者线程就被充分利用起来，这就是**事件驱动**，所谓的reactor模式。

2. 重定位：[https://blog.csdn.net/yesyes120/article/details/78944991](https://blog.csdn.net/yesyes120/article/details/78944991)
3. 一个链接的实例：[https://zhuanlan.zhihu.com/p/114348061](https://zhuanlan.zhihu.com/p/114348061)
4. **回顾 P-541**
5. P-468图7-15比较清晰的画出了动态链接的过程。动静区别在于链接阶段—可重定位目标文件、静态库和动态库通过链接器进行链接时。动态链接库的信息不会出现在链接后打包生成的可执行文件中，链接器只会拷贝一些重定位和符号表信息，在可执行目标文件加载时解析动态链接库中的数据和代码。
6. 进程切换要清空cache，更新cv3寄存器（存一级页表起始地址）。进程的上下文不仅包括了虚拟内存、栈、全局变量等用户空间的资源，还包括了内核堆栈、寄存器等内核空间的状态。
7. 中断是操作系统接管的机会，每次交互触发中断硬件才能选择执行操作系统的调度代码，否则硬件和操作系统是无法关联的。

---

其它文章：

1. 操作系统各概念：[https://zhuanlan.zhihu.com/p/58522069](https://zhuanlan.zhihu.com/p/58522069)
2. Amdahl定理相关：[https://zhuanlan.zhihu.com/p/146264596](https://zhuanlan.zhihu.com/p/146264596)
3. CPU上下文切换：[https://zhuanlan.zhihu.com/p/52845869](https://zhuanlan.zhihu.com/p/52845869)
4. RISC与CISC两者针对性能提高的区别：[https://developer.aliyun.com/article/174164](https://developer.aliyun.com/article/174164)
5. 考前看：[https://zhuanlan.zhihu.com/p/149414159](https://zhuanlan.zhihu.com/p/149414159)

---

## 题目

1. 使用SEQ的缺点（引入流水线的优点）？

    答：SEQ需要保证每一条指令在一个时钟周期内可以完成全部阶段包括取指、译码、访存、执行、写回，导致一个时钟周期设计的很长，硬件资源仅在一个时钟周期的某一个部分被使用，不能做到高效的利用。

2. 吞吐量如何计算？

    答：吞吐量=一条指令除计算时间（单位ps）乘1000，吞吐量单位是GIPS，每秒前兆条指令。

3. 限制流水线性能的因素：

    答：第一，不一致的划分，若需要执行的组合逻辑长度不等，为了保证一个时钟周期内能执行完一个组合逻辑，时钟周期就要设置为延迟最大的组合逻辑的时间长度，这样对于延迟界限较小的操作在一个周期中就会有很多时间处于空闲状态，效率低。

    第二，流水线过深，提高时钟频率，划分成的每个阶段延迟都较小，然而两阶段之间的流水线寄存器的读写会成为吞吐量的主要制约因素。

    第三，数据相关或控制相关造成的数据冒险。