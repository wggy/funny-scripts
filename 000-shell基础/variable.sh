#!/bin/sh
# 定义变量，变量名符合通用规范即可，注意，变量名和等号之间不能有空格
myname='wmmmmmj'
children_files=$(ls /home)

# 引用变量：$myname ${myname} 
echo $myname
echo ${myname}

for file in $children_files
do
	echo $file
done

# 只读变量：readonly $google_url
google_url='http://www.google.com'
echo $google_url
readonly google_url

# 删除变量：unset $google_url，注意：只读变量无法删除

# 字符串，单引号：原样输出，必须成对出现；双引号：识别变量和转义字符
# 获取字符串长度，#{#string}
str='google\n\"[google_url] is the largest search engine of the world! '
echo -e $str
echo ${#str}
str="google\n\"[$google_url] is the largest search engine of the world! "
echo -e $str
echo ${#str}

your_name="runoob"
# 使用双引号拼接
greeting="hello, "$your_name" !"
greeting_1="hello, ${your_name} !"
echo $greeting
echo $greeting_1
# 使用单引号拼接
greeting_2='hello, '$your_name' !'
greeting_3='hello, ${your_name} !'
echo $greeting_3
echo $greeting_3


# 截取字符串
echo ${str:0:6}

# 查找子字符串
str="shell is so easy!" 
echo `expr index "$str" s`

# 数组，只支持一维数组，从0索引
search_engines=(google baidu bing 360 sougou)
# 读取数组第一个元素
echo ${search_engines}
# 读取数组所有元素
echo ${search_engines[@]}
# 读取数组给定索引
echo ${search_engines[3]}
# 获取数组长度
echo ${#search_engines[@]}
# 获取数组元素的长度
echo ${#search_engines[4]}

echo ===========shell内置变量===============

# 参数传递
echo $#
echo $?
echo $*
echo $-
echo $@
echo $$
echo $!


echo ===========表达式及算术运算============
echo `expr 23 + 34`
echo `expr 44 - 21`
echo `expr 23 \* 10`
echo `expr 20 / 3`


vara=10
varb=20
if [ $vara -eq $varb ];then
	echo "$vara -eq $varb : vara 等于 varb"
else
	echo "$vara -eq $varb : vara 不等于 varb"
fi

if [ $vara -ne $varb ];then
	echo "$vara -ne $varb : vara 不等于 varb"
fi

if [ $vara -gt $varb ];then
	echo "$vara -gt $varb : vara 大于 varb"
fi

if [ $vara -lt $varb ];then
	echo "$vara -lt $varb : vara 小于 varb"
fi

if [ $vara -ge $varb ];then
	echo "$vara -ge $varb : vara 大于等于 varb"
fi

if [ $vara -le $varb ];then
	echo "$vara -le $varb : vara 小于等于 varb"
fi


echo ===========布尔运算: !表示非运算，-o表示或运算，-a表示与运算====================
if [ $vara -gt 0 -o $varb -lt 0 ]
then
	echo "$vara 大于0或者$varb 小于0"
fi

if [ $vara -gt 0 -a $varb -lt 0 ]
then
        echo "$vara 大于0并且$varb 小于100"
fi

echo "=============逻辑运算：&& ||========================="


echo "=============字符串运算：=：判等，!=：判不等，-z：判长度为0，-n：判长度非0，$：判非空"
a="abc"
b="efg"

if [ $a = $b ]
then
   echo "$a = $b : a 等于 b"
else
   echo "$a = $b: a 不等于 b"
fi
if [ $a != $b ]
then
   echo "$a != $b : a 不等于 b"
else
   echo "$a != $b: a 等于 b"
fi
if [ -z $a ]
then
   echo "-z $a : 字符串长度为 0"
else
   echo "-z $a : 字符串长度不为 0"
fi
if [ -n "$a" ]
then
   echo "-n $a : 字符串长度不为 0"
else
   echo "-n $a : 字符串长度为 0"
fi
if [ $a ]
then
   echo "$a : 字符串不为空"
else
   echo "$a : 字符串为空"
fi


echo "=============文件测试运算符，-d：判目录，-f：判普通文件，-s：判空，-e：文件是否存在========================="

dir=/opt/
if [ -d $dir ];then
	echo "$dir 是目录"
fi

if [ -e $dir ];then
	echo "$dir 目录存在"
fi

echo "==============使用printf格式化输出=========================="
printf "%-10s %-8s %-4s\n" 姓名 性别 体重kg  
printf "%-10s %-8s %-4.2f\n" 郭靖 男 66.1234 
printf "%-10s %-8s %-4.2f\n" 杨过 男 48.6543 
printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876 






