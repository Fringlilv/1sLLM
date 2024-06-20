from .db import DB, cached_property, synced_property

class Chat(DB):
    """
    存储一次会话.
    属性:
        msg_list: 消息列表
        recv_msg_tmp: 模型名-Msg, 最后一次回答的接收消息
    """

    def __init__(self, cid, title):
        super().__init__('chat')
        self._chat_id = cid
        self._chat_title = title
        self._msg_list = []
        self._recv_msg_tmp = {}

        self._db_id = cid
        self.save()

    @cached_property
    def get_chat_id(self):
        return self._chat_id

    @cached_property
    def get_chat_title(self):
        return self._chat_title

    @cached_property
    def get_msg_list(self):
        return self._msg_list

    @cached_property
    def get_recv_msg_tmp(self):
        return self._recv_msg_tmp

    @synced_property
    def set_title(self, title):
        self._chat_title = title

    @synced_property
    def add_msg(self, msg):
        self._msg_list.append(msg)

    @synced_property
    def add_recv_msg(self, model_name, msg):
        self._recv_msg_tmp[model_name] = msg

    @synced_property
    def sel_recv_msg(self, model_name):
        self._msg_list.append(self._recv_msg_tmp[model_name])
        self._recv_msg_tmp = {}

    def _db_dict(self):
        res = {
            'chat_id': self._chat_id,
            'chat_title': self._chat_title,
            'msg_list': self._msg_list,
            'recv_msg_tmp': self._recv_msg_tmp
        }
        return res
