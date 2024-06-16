# 1sLLM

一站式大模型访问：可以快捷简便的与多个大模型同时交互，比较生成内容，并随时切换。通过用户提供的API接口，将用户的提问同时发送给多个LLMs处理，然后将不同的回答整理后反馈给用户，提升访问效率和用户体验效果。

目标用户：同时使用多个大模型，需要频繁与模型交互，并希望以简便的方式获得最佳答案的人。

核心功能：

* 对比对话并列呈现
* ApiKey与历史会话管理
* 舒适的网页界面

使用方法：

* 软件要求：Python (Flask-Cors)，Flutter
* 启动前端

  ```bash
  cd frontend/ones_llm
  flutter run
  ```

* 启动后端：`python ./back/main.py`

网页截图：

![主界面](screenshots/1.png)
![设置（暂定）](screenshots/2.png)
