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
        self._username = username
        self._password = password
        self._api_dict = {}
        self._chat_dict = {}
        self._available_models = {}

        self._db_id = self._username

    def add_chat(self, chat):
        """
        添加会话.
        """
        self._chat_dict[chat.get_chat_id()] = chat
        self.save()

    def del_chat(self, chat_id):
        """
        删除会话.
        """
        del self._chat_dict[chat_id]
        self.save()

    def add_api(self, service_provider_name, api_key) -> bool:
        """
        添加/覆盖api.
        """
        self._api_dict[service_provider_name] = api_key
        self._available_models[service_provider_name] = eval(
            f"{service_provider_name}_Api")(api_key).supported_models
        self.save()

    def del_api(self, service_provider_name):
        """
        删除api.
        """
        del self._api_dict[service_provider_name]
        self.save()

    def get_username(self):
        """
        获取用户名.
        """
        return self._username

    def get_password(self):
        """
        获取密码.
        """
        return self._password

    def get_available_models(self):
        """
        获取支持的模型列表.
        """
        return self._available_models

    def get_api_dict(self):
        """
        获取api字典.
        """
        return self._api_dict

    def get_chat(self, cid):
        """
        获取chat.
        """
        return self._chat_dict.get(cid)

    def get_api(self, model_name):
        """
        获取api.
        """
        return self._api_dict.get(model_name)

    def get_chat_dict(self):
        """
        获取chat字典.
        """
        return self._chat_dict

    def _db_dict(self):
        res = {'username': self._username, 'password': self._password,
               'api_dict': self._api_dict, 'cid': list(self._chat_dict.keys())}

        return res
