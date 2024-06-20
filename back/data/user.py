from .db import DB, cached_property, synced_property

class User(DB):
    """
    存储用户信息.
    属性:
        api_dict: 服务商名-Api
        chat_dict: 会话id-Chat
        available_models: 服务商名-支持的模型列表
    """

    def __init__(self, username, password, api_dict={}, chat_dict={}, available_models={}):
        super().__init__('user')
        self._db_id = username
        self._username = username
        self._password = password
        self._api_dict = api_dict
        self._chat_dict = chat_dict
        self._available_models = available_models
        self.save()

    @cached_property
    def get_username(self):
        return self._username

    @cached_property
    def get_password(self):
        return self._password

    @cached_property
    def get_available_models(self):
        return self._available_models

    @cached_property
    def get_api_dict(self):
        return self._api_dict

    @cached_property
    def get_chat_dict(self):
        return self._chat_dict

    def get_chat(self, chat_id):
        return self.get_chat_dict().get(chat_id)

    @synced_property
    def add_chat(self, chat):
        self._chat_dict[chat.get_chat_id()] = chat

    @synced_property
    def del_chat(self, chat_id):
        del self._chat_dict[chat_id]

    @synced_property
    def add_api(self, service_provider_name, api_key):
        self._api_dict[service_provider_name] = api_key
        self._available_models[service_provider_name] = eval(
            f"{service_provider_name}_Api")(api_key).supported_models

    @synced_property
    def del_api(self, service_provider_name):
        del self._api_dict[service_provider_name]
        del self._available_models[service_provider_name]

    def get_api(self, service_provider_name):
        return self.get_api_dict().get(service_provider_name)

    def _db_dict(self):
        return {
            'username': self._username,
            'password': self._password,
            'api_dict': self._api_dict,
            'chat_dict': {k: v.get_chat_id() for k, v in self._chat_dict.items()},
            'available_models': self._available_models
        }
