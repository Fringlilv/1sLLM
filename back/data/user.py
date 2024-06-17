from db import DB

class User(DB):
    """
    存储用户信息.
    属性:
        api_dict: 服务商名-Api
        chat_dict: 会话id-Chat
        available_models: 服务商名-支持的模型列表
    """

    def __init__(self, username, password):
        self.username = username
        self.password = password
        self.api_dict = {}
        self.chat_dict = {}
        self.available_models = {}

        self._db_id = self.username

    def add_chat(self, chat):
        """
        添加会话.
        """
        self.chat_dict[chat.chat_id] = chat
        self.save()

    def del_chat(self, chat_id):
        """
        删除会话.
        """
        del self.chat_dict[chat_id]
        self.save()

    def add_api(self, service_provider_name, api_key) -> bool:
        """
        添加/覆盖api.
        """
        self.api_dict[service_provider_name] = api_key
        self.available_models[service_provider_name] = eval(f"{service_provider_name}_Api")(api_key).supported_models
        self.save()

    def del_api(self, service_provider_name):
        """
        删除api.
        """
        del self.api_dict[service_provider_name]
        self.save()

    def _db_dict(self):
        res = {'username': self.username, 'password': self.password,
               'api_dict': self.api_dict, 'cid': list(self.chat_dict.keys())}

        return res

