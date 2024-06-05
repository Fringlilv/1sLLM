class Api:
    """
    存储api信息的基类.
    """

    def __init__(self, name, key):
        self.model_name = name
        self.api_key = key


class Chat:
    """
    存储一次会话.
    属性:
        send_msg_list: 发送消息列表
        recv_msg_list: 接收消息列表 (选中的)
        recv_msg_list_tmp: 接收消息列表 (最后一次回答, 可能有多个模型)
        recv_model_dict_tmp: 模型名-recv_msg_list_tmp中的序号, 用于查找
    """

    def __init__(self, cid, title):
        self.chat_id = cid
        self.chat_title = title
        self.send_msg_list = []
        self.recv_msg_list = []
        self.recv_msg_list_tmp = []
        self.recv_model_dict_tmp = {}


class User:
    """
    存储用户信息.
    属性:
        api_dict: 模型名-api_list中的序号, 用于查找
        chat_dict: 会话id-chat_list中的序号, 用于查找
    """

    def __init__(self, username, password):
        self.username = username
        self.password = password
        self.api_list = []
        self.apt_dict = {}
        self.chat_list = []
        self.chat_dict = {}

    def add_chat(self, chat):
        """
        添加会话.
        """
        self.chat_dict[chat.chat_id] = len(self.chat_list)
        self.chat_list.append(chat)

    def add_api(self, api):
        """
        添加api.
        """
        if api.model_name in self.api_dict:
            self.api_list[self.api_dict[api.model_name]] = api
            return
        self.api_dict[api.model_name] = len(self.api_list)
        self.api_list.append(api)


class Sever:
    """
    服务器所需的一切信息.
    属性:
        user_list: 用户列表
        user_dict: 用户名-user_list中的序号, 用于查找
        session_dict: 用户名-session_id, 用于记录会话信息
    """

    def __init__(self):
        self.user_list = []
        self.user_dict = {}
        self.session_dict = {}

    def add_user(self, user):
        """
        添加用户.
        """
        self.user_dict[user.username] = len(self.user_list)
        self.user_list.append(user)

    def load(self, path):
        pass

    def save(self, path):
        pass
