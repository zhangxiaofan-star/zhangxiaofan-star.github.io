---
title: 大模型（1）前端vue创建并使用git提交自己项目
date: 2025-03-08
tags:
 - 大模型
categories:
 -  大模型
---
# 1、安装vue
```javascript
npm install @vue/cli -g   
```
如果有权限问题就使用 cmd的管理员权限打开

## 2、创建vue项目
```javascript
vue create chatgpt-project
```
注意：在vscode中配置git
1、在setting.json文件加入如下配置
```javascript
    "http.proxy": "http://127.0.0.1:7890",  #代理（clash）
    "https.proxy": "http://127.0.0.1:7890", #代理（clash）
    "http.proxyStrictSSL": false,
    "remote.SSH.httpProxy": "",
    "git.path": "D:/Program Files/Git/cmd/git.exe",   # git安装目录
```
2、vscode的终端需要先输入如下命令
```javascript
git config --global https.proxy http://127.0.0.1:7890
```
##  3、安装axios
这个是用来做http请求的
```javascript
npm install axios --save
```
##  4、编写界面
#### 1、创建<kbd>\src\components\chatwindow.vue</kbd>, 并添加如下代码
```javascript
<template>
  <div class="chat-container">
    <div class="chat-window">
      <div class="messages" ref="messagesContainer">
        <div 
          v-for="(message, index) in messages" 
          :key="index" 
          class="message" 
          :class="{ 'user-message': message.sender === 'user', 'bot-message': message.sender === 'bot' }"
        >
          {{ message.text }}
        </div>
      </div>
      <div class="input-container">
        <input 
          type="text" 
          v-model="inputMessage" 
          @keyup.enter="sendMessage" 
          placeholder="输入你的问题..."
        />
        <button @click="sendMessage">发送</button>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      messages: [],
      inputMessage: "",
    };
  },
  methods: {
    sendMessage() {
      if (this.inputMessage.trim() !== "") {
        const userText = this.inputMessage;
        this.messages.push({ text: userText, sender: "user" });
        this.inputMessage = ""; // 清空输入框
        this.$nextTick(() => this.scrollToBottom());
        this.fetchResponse(userText);
      }
    },
    async fetchResponse(userText) {
      try {
        const response = await axios.post(
          "https://api.openai.com/v1/chat/completions",
          {
            model: "gpt-3.5-turbo",
            messages: [{ role: "user", content: userText }],
            max_tokens: 150,
          },
          {
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer YOUR_API_KEY`,
            },
          }
        );
        const botReply = response.data.choices[0].message.content.trim();
        this.messages.push({ text: botReply, sender: "bot" });
        this.$nextTick(() => this.scrollToBottom());
      } catch (error) {
        console.error("请求失败", error);
        this.messages.push({ text: "请求失败，请检查API Key", sender: "bot" });
      }
    },
    scrollToBottom() {
      this.$refs.messagesContainer.scrollTop = this.$refs.messagesContainer.scrollHeight;
    },
  },
};
</script>

<style scoped>
/* 全局背景 */
.chat-container {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background: linear-gradient(to right, #667eea, #764ba2);
}

/* 聊天窗口 */
.chat-window {
  width: 400px;
  height: 500px;
  display: flex;
  flex-direction: column;
  border-radius: 12px;
  background: white;
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

/* 消息区域 */
.messages {
  flex: 1;
  padding: 10px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 10px;
  background: #f9f9f9;
}

/* 消息样式 */
.message {
  max-width: 80%;
  padding: 10px 15px;
  border-radius: 18px;
  font-size: 14px;
  line-height: 1.4;
  word-wrap: break-word;
}

/* 用户消息 */
.user-message {
  align-self: flex-end;
  background: #667eea;
  color: white;
}

/* 机器人消息 */
.bot-message {
  align-self: flex-start;
  background: #e5e5ea;
  color: black;
}

/* 输入框 & 发送按钮 */
.input-container {
  display: flex;
  padding: 10px;
  background: #fff;
  border-top: 1px solid #ddd;
}

.input-container input {
  flex: 1;
  padding: 10px;
  border: none;
  border-radius: 20px;
  background: #f1f1f1;
  outline: none;
  font-size: 14px;
  transition: 0.3s;
}

.input-container input:focus {
  background: #e1e1e1;
}

.input-container button {
  margin-left: 10px;
  padding: 10px 15px;
  border: none;
  background: #667eea;
  color: white;
  border-radius: 20px;
  cursor: pointer;
  transition: 0.3s;
}

.input-container button:hover {
  background: #564bb5;
}
</style>
```
#### 2、更改<kbd>\src\App.vue</kbd>, 并添加如下代码
```javascript
<template>  
  <div id="app">  
    <ChatWindow />  
  </div>  
</template>  
  
<script>  
import ChatWindow from './components/ChatWindow.vue';  
  
export default {  
  name: 'App',  
  components: {  
    ChatWindow  
  }  
};  
</script>  
  
<style>  
#app {  
  font-family: 'Avenir', Helvetica, Arial, sans-serif;  
  -webkit-font-smoothing: antialiased;  
  -moz-osx-font-smoothing: grayscale;  
  text-align: center;  
  color: #2c3e50;  
  margin-top: 60px;  
}  
html, body, #app {
  margin: 0;
  padding: 0;
  height: 100vh;
  width: 100vw;
  overflow: hidden;
}
</style>  
```


## 5、运行前端
```javascript
npm run serve
```


## 6、提交github
1、先拉取我的原创仓库项目，然后添加更改
```javascript
git add .
```
2、添加提交
```javascript
git commit -m "vue前端架构"
```
3、上传提交
```javascript
git push
```

 [1]:https://www.oryoy.com/news/cong-ling-kai-shi-yong-vue-qing-song-da-zao-chat-gpt-liao-tian-jie-mian.html

