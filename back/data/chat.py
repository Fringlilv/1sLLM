from db import DB

class Chat(DB):
    """
    存储一次会话.
    属性:
        msg_list: 消息列表
        recv_msg_tmp: 模型名-Msg, 最后一次回答的接收消息
    """

    def __init__(self, cid, title):
        self._chat_id = cid
        self._chat_title = title
        self._msg_list = []
        self._recv_msg_tmp = {}

        self._db_id = self._chat_id

    def set_title(self, title):
        """
        设置标题.
        """
        self._chat_title = title
        self.save()

    def add_msg(self, msg):
        """
        添加消息.
        """
        self._msg_list.append(msg)
        self.save()

    def add_recv_msg(self, model_name, msg):
        """
        添加接收消息.
        """
        self._recv_msg_tmp[model_name] = msg
        self.save()

    def sel_recv_msg(self, model_name):
        """
        选择接收消息.
        """
        self._msg_list.append(self._recv_msg_tmp[model_name])
        self._recv_msg_tmp = {}
        self.save()

    def get_chat_id(self):
        """
        获取chat_id.
        """
        return self._chat_id

    def get_recv_msg_tmp(self):
        """
        获取recv_msg_tmp.
        """
        return self._recv_msg_tmp

    def __dict__(self):
        res = {'chat_id': self._chat_id,
               'chat_title': self._chat_title, 'msg_list': self._msg_list}
        if self._recv_msg_tmp:
            res['recv_msg_tmp'] = self._recv_msg_tmp
        return res

    def _db_dict(self):
        return self.__dict__()

