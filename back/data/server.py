import hashlib
import random
import time
from db import DB
from chat import Chat
from user import User

class Server(DB):
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
    
    def _db_dict(self):
        pass
