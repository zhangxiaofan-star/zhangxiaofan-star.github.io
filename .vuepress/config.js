
module.exports = {

  "title": "张小凡",
  "description": "我的博客",
  "dest": "public",

  "head": [
    // 预连接到字体服务
    ["link", { rel: "preconnect", href: "https://cdn.jsdelivr.net/npm/@callmebill/lxgw-wenkai-web@latest", crossorigin: "anonymous" }],
    // 导入 LXGW Wenkai 字体样式表
    ["link", {
      rel: "stylesheet",
      href: "https://cdn.jsdelivr.net/npm/@callmebill/lxgw-wenkai-web@latest/style.css"
    }],
    [
      "link",
      {
        "rel": "icon",
        "href": "/favicon.ico"
      }
    ],
    [
      "meta",
      {
        "name": "viewport",
        "content": "width=device-width,initial-scale=1,user-scalable=no"
      }
    ]
  ],
  "theme": "reco",
  "themeConfig": {

    // 子侧边栏
    subSidebar: 'auto',
    sidebarDepth: 1,
    lastUpdated: '更新时间',
    // 设置时区偏移量（8小时）
    timezoneOffset: 8 * 60 * 60 * 1000,
    search: true,
    "nav": [
      {
        "text": "Home",
        "link": "/",
        "icon": "reco-home"
      },
      {
        "text": "TimeLine",
        "link": "/timeline/",
        "icon": "reco-date"
      },
      // {
      //   "text": "Docs",
      //   "icon": "reco-message",
      //   "items": [
      //     {
      //       "text": "vuepress-reco",
      //       "link": "/docs/theme-reco/"
      //     }
      //   ]
      // },
      {
        "text": "Contact",
        "icon": "reco-message",
        "items": [
          {
            "text": "Gitee",
            "link": "https://gitee.com/zhang-xiaofanQWQ",
            "icon": "reco-mayun"
          },
          {
            "text": "CSDN",
            "link": "https://blog.csdn.net/qq_44667233?type=blog",
            "icon": "reco-csdn"
          },
          {
            "text": "GitHub",
            "link": "https://github.com/zhangxiaofan-star",
            "icon": "reco-github"
          }
        ]
      }
    ],
    "sidebar": {
      "/blogs/category1/": [
        {
          title: 'Category1：esp32开发',
          collapsable: true,
          children: [
            { title: '1、esp32点亮led灯', path: '/blogs/category1/2024/1、esp32点亮led灯' }
          ]
        }
      ],
      "/blogs/category2/": [
        {
          title: 'Category2：大模型',
          collapsable: true,
          children: [
            { title: 'hugging face模型微调（1）新闻文本分类', path: '/blogs/category2/2022/hugging face模型微调（1）新闻文本分类' },
            { title: 'ollama+qwen2.5+openwebui部署', path: '/blogs/category2/2024/ollama+qwen2.5+openwebui部署' },
            { title: '大模型（1）前端vue创建并使用git提交自己项目', path: '/blogs/category2/2025/大模型（1）前端vue创建并使用git提交自己项目' },
            { title: '大模型（2）后端springboot以及mysql在远程服务器端docker部署方式', path: '/blogs/category2/2025/大模型（2）后端springboot以及mysql在远程服务器端docker部署方式' },
          ]
        }
      ],
      "/blogs/category3/": [
        {
          title: 'Category3：后端开发',
          collapsable: true,
          children: [
            { title: 'springboot后端管理', path: '/blogs/category3/2022/springboot后端管理' }
          ]
        }
      ],
    },
    "type": "blog",
    "blogConfig": {
      "category": {
        "location": 2,
        "text": "Category"
      },
      "tag": {
        "location": 3,
        "text": "Tag"
      }
    },
    // "friendLink": [
    //   {
    //     "title": "张小凡",
    //     "desc": "君子无争，含光无形，坐忘无心",
    //     "email": "2301246784@qq.com",
    //     "link": "https://gitee.com/zhang-xiaofanQWQ"
    //   },
    //   {
    //     "title": "vuepress-theme-reco",
    //     "desc": "A simple and beautiful vuepress Blog & Doc theme.",
    //     "avatar": "https://vuepress-theme-reco.recoluan.com/icon_vuepress_reco.png",
    //     "link": "https://vuepress-theme-reco.recoluan.com"
    //   }
    // ],
    "logo": "/logo.png",
    "search": true,
    "searchMaxSuggestions": 10,
    "lastUpdated": "Last Updated",
    "author": "zxf",
    "authorAvatar": "/logo.png",
    "record": "xxxx",
    "startYear": "2022"
  },
  plugins: [
    [
      //彩带背景 先安装在配置， npm install vuepress-plugin-ribbon --save
      "ribbon",
      {
        size: 90,     // width of the ribbon, default: 90
        opacity: 0.8, // opacity of the ribbon, default: 0.3
        zIndex: -1    // z-index property of the background, default: -1
      }
    ],
    [
      //先安装在配置， npm install @vuepress-reco/vuepress-plugin-kan-ban-niang --save
      "@vuepress-reco/vuepress-plugin-kan-ban-niang",
      {
        theme: ['blackCat', 'whiteCat', 'haru1', 'haru2', 'haruto', 'koharu', 'izumi', 'shizuku', 'wanko', 'miku', 'z16'],
        clean: false,
        messages: {
          welcome: '我是lookroot欢迎你的关注 ',
          home: '心里的花，我想要带你回家。',
          theme: '好吧，希望你能喜欢我的其他小伙伴。',
          close: '再见哦'
        },
        width: 240,
        height: 352
      }
    ],
    [
      //鼠标点击特效 先安装在配置， npm install vuepress-plugin-cursor-effects --save
      "cursor-effects",
      {
        size: 3,                    // size of the particle, default: 2
        shape: 'star',  // shape of the particle, default: 'star'
        zIndex: 999999999           // z-index property of the canvas, default: 999999999
      }
    ],
    [
      //图片放大插件 先安装在配置， npm install vuepress-plugin-dynamic-title --save
      '@vuepress/plugin-medium-zoom', {
        selector: '.page img',
        delay: 1000,
        options: {
          margin: 24,
          background: 'rgba(25,18,25,0.9)',
          scrollOffset: 40
        }
      }
    ],
    [
      //音乐播放器 先安装在配置， npm install vuepress-plugin-bgm-player --save
      '@vuepress-reco/vuepress-plugin-bgm-player',
      {
        audios: [
          {
            name: '秦王破阵乐',
            artist: '柳青瑶',
            url: '/bgm.mp3',
            cover: 'bgm.jpg'
          }
        ],
        // 是否默认缩小
        autoShrink: true,
        // 缩小时缩为哪种模式
        shrinkMode: 'float',
        // 悬浮窗样式
        floatStyle: { bottom: '10px', 'z-index': '999999' }
      }
    ],
    [
      //插件广场的流程图插件 先安装在配置 npm install vuepress-plugin-flowchart --save
      'flowchart'
    ],
    [
      'vuepress-plugin-comment',
      {
        choosen: 'valine',
        // options选项中的所有参数，会传给Valine的配置
        options: {
          el: '#valine-vuepress-comment',
          appId: 'T5u75P5IuGIzxVmtw9ahOGMi-gzGzoHsz',
          appKey: 'mV973BceAWbzzAqiYk700n09'
        }
      }
    ],

    // [
    //   //插件广场的sitemap插件 先安装在配置 npm install vuepress-plugin-sitemap --save
    //   'sitemap', {
    //     hostname: 'https://www.glassysky.site'
    //   }
    // ],

  ],
  "markdown": {
    "lineNumbers": true
  }
}