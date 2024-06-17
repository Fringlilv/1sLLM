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
        self._user_dict = {}
        self._session_dict = {}

    def add_user(self, user : User):
        """
        添加用户.
        """
        self._user_dict[user.get_username()] = user

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

    def get_chat(self, user : User, cid) -> Chat:
        """
        获取chat.
        """
        chat = user.get_chat(cid)
        if chat is None:
            return None
        return chat

    def get_user(self, uname, sid) -> User:
        """
        检查session_id.
        """
        if uname is None or sid is None:
            return None
        if self._session_dict.get(uname) == sid:
            return self._user_dict[uname]
        return None

    def check_user_name_exist(self, uname):
        """
        检查用户名是否存在.
        """
        return uname in self._user_dict
    
    def get_password_md5(self, uname):
        """
        获取用户密码的md5.
        """
        return self._user_dict[uname].get_password()
    
    def set_session_dict(self, key, value):
        """
        设置session_dict.
        """
        self._session_dict[key] = value

    def pop_session_dict(self, key):
        """
        删除session_dict.
        """
        self._session_dict.pop(key)

    def _db_dict(self):
        pass
