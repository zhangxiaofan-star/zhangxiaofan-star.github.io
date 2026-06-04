---
title: hugging face模型微调（1）新闻文本分类
date: 2022-12-07
tags:
  - 大模型
categories:
  - 大模型
---
本文借鉴：[1]https://blog.csdn.net/sinat_28931055/article/details/119560054
[2]https://zhuanlan.zhihu.com/p/537271887
#  1、hugging  face介绍
 [hugging face](https://huggingface.co/)总部位于纽约，是一家专注于自然语言处理、人工智能和分布式系统的创业公司。他们所提供的聊天机器人技术一直颇受欢迎，但更出名的是他们在NLP开源社区上的贡献。Huggingface一直致力于自然语言处理NLP技术的平民化(democratize)，希望每个人都能用上最先进(SOTA, state-of-the-art)的NLP技术，而非困窘于训练资源的匮乏。同时Hugging Face专注于NLP技术，拥有大型的开源社区。尤其是在github上开源的自然语言处理，预训练模型库 Transformers，已被下载超过一百万次，github上超过24000个star。Transformers 提供了NLP领域大量state-of-art的 预训练语言模型结构的模型和调用框架。           
# 2、环境安装
##### transformers
清华源安装transformers
```
pip install transformers  -i https://pypi.tuna.tsinghua.edu.cn/simple/
```
# 3、模型下载
由于
```
model = BertForSequenceClassification.from_pretrained(pretrain_Model_path)
```
经常会遇到网络中断的问题，所以可以到huggingface官网下载。
***config.json:模型的结构文件
pytorch_model.bin:模型的权重
vocab.txt:模型所用的词表***
![在这里插入图片描述](/1-hugging/1.png)

这三个文件下载好之后，把它复制到自己的项目之中(**huggingface_test**)
![项目目录](/1-hugging/2.png)
# 4、数据预处理
##### 1、数据集介绍（训练集）
![数据集](/1-hugging/3.png)
可以看到数据集的类型为 ```句子\t标签```
##### 2、数据集处理（训练集）
**1、导入包**
```javascript
// 导入的包
import re
from sklearn.utils import shuffle
import pandas as pd
import torch
from torch.utils.data import TensorDataset, DataLoader, RandomSampler, SequentialSampler
from transformers import AutoModelForSequenceClassification
from transformers import AutoTokenizer
import numpy as np
```
**2、标签定义，总共有10个标签分类**
```javascript
// 标签字典
label_dic = {
 'finance':0,
 'realty':1,
 'stocks':2,
 'education':3,
 'science':4,
 'society':5,
 'politics':6,
 'sports':7,
 'game':8,
 'entertainment':9}
```
**3、数据预处理**
（1）使用get_train_data函数读取训练集，制作成两个list，并添加到一个字典中。
（2）只使用前8000个数据进行训练。
```javascript
def get_train_data(file,label_dic):
    content = []
    label = []
    with open(file, "r", encoding="utf-8") as f:
        for i in f.readlines():
            c,l = i.split("\t")
            content.append(re.sub('[^\u4e00-\u9fa5]',"",c))
            
            label.append(int(l.strip()))
    return content,label

content,label = get_train_data('D:\\project_vscode\\Python\\nlp\\huggingface_test\\train.txt',label_dic=label_dic)
data = pd.DataFrame({"content":content,"label":label})
# data = shuffle(data)
train_data = tokenizer(data.content.to_list()[:8000], padding = "max_length", max_length = 40, truncation=True ,return_tensors = "pt")
train_label = data.label.to_list()[:8000]
```
# 5、模型加载
##### 1、分词器和模型加载
就是导入之前下载的文件
```javascript
tokenizer = AutoTokenizer.from_pretrained("D:\\project_vscode\\Python\\nlp\\huggingface_test\\")
model = AutoModelForSequenceClassification.from_pretrained("D:\\project_vscode\\Python\\nlp\\huggingface_test\\", num_labels=10)
```
##### 2、定义优化器和学习率
在AutoModelForSequenceClassification.from_pretrained("./path", num_labels=10) 这个函数中，transformer 已经帮你定义了损失函数，既10个分类的交叉熵损失，所以下方我们只需要自己定义优化器和学习率即可。
```javascript
batch_size = 16
train = TensorDataset(train_data["input_ids"], train_data["attention_mask"], torch.tensor(train_label))

train_sampler = RandomSampler(train)
train_dataloader = DataLoader(train, sampler=train_sampler, batch_size=batch_size)
# 定义优化器
from torch.optim import AdamW
optimizer = AdamW(model.parameters(), lr=1e-4)
# 定义学习率和训练轮数
num_epochs = 1
from transformers import get_scheduler
num_training_steps = num_epochs * len(train_dataloader)
lr_scheduler = get_scheduler(
    name="linear", optimizer=optimizer, num_warmup_steps=0, num_training_steps=num_training_steps
)
```
# 6、模型训练
```java
device = torch.device("cpu") 
# device = torch.device("cuda") if torch.cuda.is_available() else torch.device("cpu") 因为我的pytorch环境是cpu，所以用的不是cuda
model.to(device)

for epoch in range(num_epochs):
    total_loss = 0
    model.train()
    for step, batch in enumerate(train_dataloader):
        if step % 10 == 0 and not step == 0:
            print("step: ",step, "  loss:",total_loss/(step*batch_size))
        b_input_ids = batch[0].to(device)
        b_input_mask = batch[1].to(device)
        b_labels = batch[2].to(device)
        model.zero_grad()        
        outputs = model(b_input_ids, 
                    token_type_ids=None, 
                    attention_mask=b_input_mask, 
                    labels=b_labels)

        loss = outputs.loss       
        total_loss += loss.item()
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
        optimizer.step()
        lr_scheduler.step()
    avg_train_loss = total_loss / len(train_dataloader)      
    print("avg_loss:",avg_train_loss)
```
# 7、测试
```java
test = tokenizer("词汇阅读是关键 08年考研暑期英语复习全指南",return_tensors="pt",padding="max_length",max_length=100)
model.eval()
with torch.no_grad():  
    outputs = model(test["input_ids"], 
                    token_type_ids=None, 
                    attention_mask=test["attention_mask"])
pred_flat = np.argmax(outputs["logits"],axis=1).numpy().squeeze()
print(pred_flat.tolist())
```
# 8、实验结果
测试句子，分类是3
![在这里插入图片描述](/1-hugging/4.png)
下图可以看到实验结果分类就是3

![在这里插入图片描述](/1-hugging/5.png)


