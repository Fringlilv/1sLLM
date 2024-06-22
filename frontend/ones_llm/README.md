# ones_llm

这是1sLLM的前端，使用 [flutter](https://docs.flutter.cn/) 编写。

## 运行方法

运行前保证已正确[安装](https://docs.flutter.cn/get-started/install)flutter。目前已测试：

- 本地调试环境下web端及windows端
- 构建发布下wen端

不保证其他平台下的表现。

### 本地调试
使用以下命令进行本地调试
``` cmd
flutter run
```
### 构建发布
使用以下命令构建web端
```cmd
flutter build build web --source-maps --web-renderer html
```
打包后的代码位于`./build/web`，运行前请注意调整`./build/web/index.html`中的`<base href="/">`
> 注：如果不指定 web-renderer 为 html 可能导致 edge 无法正常打开，原因未知。

## 项目结构

项目外层主要目录及文件如下
```
ones_llm
├──android                  # 用于构建android平台
├──build                    # 构建输出路径
├──ios                      # 用于构建ios平台
├──lib                      # 前端源码
├──linux                    # 用于构建linux平台
├──macos                    # 用于构建macos平台
├──test         
├──web                      # 用于构建web平台
├──windows                  # 用于构建windows平台
├──analysis_options.yaml
├──devtools_options.yaml
├──pubspec.lock
├──pubspec.yaml             # 项目设置文件
└──README.md
```

源代码位于`./lib `内，其中结构如下(未来随代码修改随时可能重构)：
```
lib
├──components               # UI组件
├──configs                  # 初始化及多语言等设置
├──controller               # 页面逻辑
├──crossPlatform            # 跨平台组件
├──pages                    # UI页面
├──services                 # 数据提供
└──main.dart                # 启动文件
```
### 依赖结构
- UI 依赖: 

```
pages(页面) -> components(页面级组件) -> components/同名文件夹(组合组件) -> (.../同名文件夹内文件)* -> components/common(基础组件)
```
页面在pages目录下，处理宽屏及窄屏下页面级组件的排列；components内为页面级组件，其中复杂组件被提取到同名文件夹下(例如components/chat.dart中组件被提取到components/chat目录下)，仍然复杂的组件递归提取(例如components/chat/markdown)；通用组件提取到components/common中，按照组件类型分类。

- 逻辑调用:

```
components -> controller -> services
```
页面级组件状态存储于controller，并调用controller提供的接口函数；controller内处理业务逻辑；controller通过services来调用api获取后端数据，或调用local读取本地数据。

