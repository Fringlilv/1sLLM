from .db import DB
from .chat import Chat

class User(DB):
    """
    存储用户信息.
    属性:
        api_dict: 服务商名-Api
        chat_dict: 会话id-Chat
        available_models: 服务商名-支持的模型列表
    """

    def __init__(self, username=None, password=None, api_dict={}, chat_dict={}, available_models={}):
        super().__init__(
            set_name='user', 
            db_id=username,
            db_dict={
                'username': username,
                'password': password,
                'api_dict': api_dict,
                'chat_dict': chat_dict,
                'available_models': available_models
            }
        )
        
    @staticmethod
    def _to_db_dict(obj) -> dict:
        '''
        将对象转换为可保存至mongodb的字典.
        '''
        return {
            'username': obj.get_username(),
            'password': obj.get_password(),
            'api_dict': obj.get_api_dict(),
            'chat_dict': {k: Chat()._to_db_dict(v) for k, v in obj.get_chat_dict().items()},
            'available_models': obj.get_available_models()
        }
        
    @staticmethod
    def _from_db_dict(db_dict: dict) -> None:
        username = db_dict['username']
        password = db_dict['password']
        api_dict = db_dict['api_dict']
        chat_dict = {k: Chat()._from_db_dict(v) for k, v in db_dict['chat_dict'].items()}
        available_models = db_dict['available_models']
        
        return {
            'username': username,
            'password': password,
            'api_dict': api_dict,
            'chat_dict': chat_dict,
            'available_models': available_models
        }
    
    def get_username(self):
        return self.get('username')

    def get_password(self):
        return self.get('password')

    def get_available_models(self):
        return self.get('available_models')

    def get_api_dict(self):
        return self.get('api_dict')
    
    def get_chat_dict(self):
        return self.get('chat_dict')

    def get_chat(self, chat_id):
        return self.get_chat_dict().get(chat_id)

    def add_chat(self, chat):
        current_chat_dict = self.get_chat_dict()
        current_chat_dict[chat.get_chat_id()] = chat
        current_chat_dict = {chat_id: Chat()._to_db_dict(chat) for chat_id, chat in current_chat_dict.items()}
        self.update('chat_dict', current_chat_dict)

    def del_chat(self, chat_id):
        current_chat_dict = self.get_chat_dict()
        del current_chat_dict[chat_id]
        current_chat_dict = {chat_id: Chat()._to_db_dict(chat) for chat_id, chat in current_chat_dict.items()}
        self.update('chat_dict', current_chat_dict)

    def add_api(self, service_provider_name, api_key):
        current_api_dict = self.get_api_dict()
        current_api_dict[service_provider_name] = api_key
        self.update('api_dict', current_api_dict)
        current_available_models = self.get_available_models()
        current_available_models[service_provider_name] = eval(
            f"{service_provider_name}_Api")(api_key).supported_models
        self.update('available_models', current_available_models)

    def del_api(self, service_provider_name):
        current_api_dict = self.get_api_dict()
        current_available_models = self.get_available_models()
        del current_api_dict[service_provider_name]
        del current_available_models[service_provider_name]
        self.update('api_dict', current_api_dict)
        self.update('available_models', current_available_models)

    def get_api(self, service_provider_name):
        return self.get_api_dict().get(service_provider_name)