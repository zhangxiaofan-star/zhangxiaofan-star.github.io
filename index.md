
# 1、安装驱动

我购买的esp32开发板是ch340串口，这个驱动是问客服要的，也可以下载ch340的驱动链接: [ch340串口驱动链接](https://www.wch.cn/download/CH341SER_EXE.html)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3fc0cff468764b81acb90521cc24e5f3.png)

安装驱动之后就可以看到串口号，如下图的com4就是我们的串口号
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3bb4a5573458435fbc37ffb069963653.jpeg)
# 2、下载vscode以及platform IO插件
下载vscode之后，在扩展中安装这个插件
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/10b280b6e0a249f3b4f39e79ed81d938.png)
# 3、创建项目
第一次创建需要下载各种配置文件，会有些慢。可以梯梯。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/30f4ff31585d486da86b81e305b04af4.jpeg)
# 4、编写程序
代码主要是在src/main.cpp中改，如下图中的代码就是点亮led灯
led是在2号引脚控制
```
//setup函数的作用是初始化，该函数只会在单片机通电的时候执行一次，该函数执行完毕之后，会无限循环执行loop函数中的逻辑。

void setup() {
  //这是setup函数的逻辑，其中的pinMode函数这一行，表示将2号引脚的工作模式设置为输出模式，只有开发板引脚设置为输出模式，才能控制外部设备的运行；
  pinMode(2,OUTPUT);
}

void loop() {
  //这是loop函数的逻辑，首先通过digitalWrite函数向2号引脚输出高电平，然后调用delay函数延迟1000毫秒，随后再向2号引脚输出低电平，最后再延迟1000毫秒
  digitalWrite(2,HIGH);
  delay(1000);
  digitalWrite(2,LOW);
  delay(1000);
}
```
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c9b37c42534b4ac0b2258b954a5832be.jpeg)
# 5、实验结果
下图中我们的led灯就点亮了
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/adb8ffa544c041bcb6fef5d27d8ceb03.jpeg)
