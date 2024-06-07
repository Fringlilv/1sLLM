import hashlib
import random
import time

class Api:
    """
    存储api信息的基类.
    """

    def __init__(self, name, key):
        self.model_name = name
        self.api_key = key

    def get_response(self, chat):
        """
        获取回复.
        """
        msg_list = [m.__dict__() for m in chat.msg_list]
        print(msg_list)
        return '111'

    def __dict__(self):
        return {'model_name': self.model_name, 'api_key': self.api_key}


class Message:
    """
    存储一条消息.
    """

    def __init__(self, role, msg):
        self.role = role
        self.msg = msg

    def __dict__(self):
        return {'role': self.role, 'msg': self.msg}


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
        api_dict: 模型名-Api
        chat_dict: 会话id-Chat
    """

    def __init__(self, username, password):
        self.username = username
        self.password = password
        self.api_dict = {}
        self.chat_dict = {}

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

    def add_api(self, api):
        """
        添加/覆盖api.
        """
        self.api_dict[api.model_name] = api

    def del_api(self, model_name):
        """
        删除api.
        """
        del self.api_dict[model_name]


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

    def load(self, path):
        pass

    def save(self, path):
        pass
