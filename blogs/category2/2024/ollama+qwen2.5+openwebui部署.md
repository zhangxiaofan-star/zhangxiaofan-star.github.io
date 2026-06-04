---
title: ollama+qwen2.5+openwebui部署
date: 2024-12-26
tags:
  - 大模型
categories:
  - 大模型
---
# ollama+qwen2.5+openwebui部署
## 1、ollama配置（docker方式）

由于curl方式我一直获取不到，所以使用docker方式
### 1.1、获取ollama
```javascript
# 注意外部主机端口号尽量使用11434端口，因为openwebui默认端口就是11434，

# CPU
sudo docker run -d -v ollama:/root/.ollama -p 11434:11434 --restart unless-stopped --name ollama ollama/ollama
# GPU 单卡
sudo docker run -d --gpus "device=1" -v ollama:/root/.ollama -p 11434:11434 --restart unless-stopped --name ollama ollama/ollama
# GPU 多卡
sudo docker run -d --gpus '"device=0,1"' -v ollama:/root/.ollama -p 11434:11434 --restart unless-stopped --name ollama ollama/ollama
```
### 1.2、进入ollama容器并安装qwen2.5：32b
```javascript
# 进入容器
sudo docker exec -it ollama /bin/bash

# 安装 我用的32b，24g显存就够，如果是16g显存，建议使用7b的
ollama run qwen2.5:32b    
```
### 1.3、验证qwen2.5：32b（docker外部）
```javascript
curl http://127.0.0.1:11434/api/chat -d '{
  "model": "qwen2.5:32b",
  "messages": [
    { "role": "user", "content": "why is the sky blue?" }
  ]
}'
```
结果如下所示
![在这里插入图片描述](/1-ollama/1.jpeg)

## 2、openwebui配置
### 2.1、openwebui安装

```javascript
#  将${inner_ip}替换成你服务器IP,不是127.0.0.1
docker run -d -p 3000:8080 -e OLLAMA_BASE_URL=http://${inner_ip}:11434 -v open-webui:/app/backend/data --name open-webui --restart always ghcr.io/open-webui/open-webui:main
```
### 2.2、openwebui浏览器访问
由于我的服务器ssh可以登录，但是ping不通，所以我在外部映射了一个端口
```javascript
#  将${inner_ip}替换成你服务器IP,不是127.0.0.1
ssh -L 3000:127.0.0.1:3000 username@${inner_ip}

# 查看openwebui日志
sudo docker logs -f open-webui
```
首次登录就是管理员账户
![在这里插入图片描述](/1-ollama/2.jpeg)
登陆之后就是chat界面，有我们的配置的qwen2.5：32b
![在这里插入图片描述](/1-ollama/3.jpeg)
选好模型开始聊天
![在这里插入图片描述](/1-ollama/4.jpeg)
## 3、python代码调用
```javascript
import requests,os,json
import pandas as pd


def send_message_to_ollama(message, port=11434):
    url = f"http://localhost:{port}/api/chat"
    payload = {
        "model": "qwen2.5:32b",
        "messages":[
                    {'role': 'system', 'content': '请判断这段新闻是否是关于发生洪水的,而且有发生洪水的具体时间,包括年月日,如果是就回答1,不是就回答0'},
                    {'role': 'user', 'content': message}
                ],
    }
    response = requests.post(url, json=payload)
    if response.status_code == 200:
        response_content = ""
        for line in response.iter_lines():
            if line:
                response_content += json.loads(line)["message"]["content"]
        return response_content
    else:
        return f"Error: {response.status_code} - {response.text}"
    
if __name__ == "__main__":
    user_input = "2023年7月5日今年大旱"
    response = send_message_to_ollama(user_input)
    print("Ollama's response:")
    print(response)
```
