import hashlib
import random
import time
from api import *

class Message:
    """
    存储一条消息.
    """

    def __init__(self, role, name, msg):
        self.role = role
        self.name = name
        self.msg = msg

    def __dict__(self):
        return {'role': self.name, 'content': self.msg}
    
    def to_role_dict(self):
        return {'role': self.role, 'content': self.msg}


class Chat:
    """
    存储一次会话.
    属性:
        msg_list: 消息列表
        recv_msg_tmp: 模型名-Msg, 最后一次回答的接收消息
    """

    def __init__(self, cid, title):
        self.chat_id = cid
        self.chat_title = title
        self.msg_list = []
        self.recv_msg_tmp = {}

    def set_title(self, title):
        """
        设置标题.
        """
        self.chat_title = title

    def add_msg(self, msg):
        """
        添加消息.
        """
        self.msg_list.append(msg)

    def add_recv_msg(self, model_name, msg):
        """
        添加接收消息.
        """
        self.recv_msg_tmp[model_name] = msg

    def sel_recv_msg(self, model_name):
        """
        选择接收消息.
        """
        self.msg_list.append(self.recv_msg_tmp[model_name])
        self.recv_msg_tmp = {}

    def __dict__(self):
        res = {'chat_id': self.chat_id,
               'chat_title': self.chat_title, 'msg_list': self.msg_list}
        if self.recv_msg_tmp:
            res['recv_msg_tmp'] = self.recv_msg_tmp
        return res


class User:
    """
    存储用户信息.
    属性:
        api_dict: 服务商名-Api
        chat_dict: 会话id-Chat
        available_models: 可用模型 
    """

    def __init__(self, username, password):
        self.username = username
        self.password = password
        self.api_dict = {}
        self.chat_dict = {}
        self.available_models = {}

    def add_chat(self, chat):
        """
        添加会话.
        """
        self.chat_dict[chat.chat_id] = chat

    def del_chat(self, chat_id):
        """
        删除会话.
        """
        del self.chat_dict[chat_id]

    def add_api(self, service_provider_name, api_key):
        """
        添加/覆盖api.
        """
        self.api_dict[service_provider_name] = api_key
        self.available_models[service_provider_name] = eval(f"{service_provider_name}_Api")(api_key).supported_models

    def del_api(self, service_provider_name):
        """
        删除api.
        """
        del self.api_dict[service_provider_name]


class Sever:
    """
    服务器所需的一切信息.
    属性:
        user_dict: 用户名-User
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

    def gen_chat_id(self, username):
        """
        生成chat_id.
        """
        txt = username + time.strftime('%Y_%m_%d_%H_%M_%S',
                                       time.localtime()) + str(random.randint(0, 100))
        cid = hashlib.md5(txt.encode('utf-8')).hexdigest()
        return cid

    def gen_session_id(self, username):
        """
        生成session_id.
        """
        txt = username + str(time.time())
        sid = hashlib.md5(txt.encode('utf-8')).hexdigest()
        return sid

    def get_chat(self, user, cid) -> Chat:
        """
        获取chat.
        """
        chat = user.chat_dict.get(cid)
        if chat is None:
            return None
        return chat

    def get_user(self, uname, sid) -> User:
        """
        检查session_id.
        """
        if uname is None or sid is None:
            return None
        if self.session_dict.get(uname) == sid:
            return self.user_list[self.user_dict[uname]]
        return None

    def check_user_name_exist(self, uname):
        """
        检查用户名是否存在.
        """
        return uname in self.user_dict

    def load(self, path):
        pass

    def save(self, path):
        pass
