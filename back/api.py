import http.client
import json

class LockAndSubclassTrackingMeta(type):
    def __init__(cls, name, bases, dct):
        super().__init__(name, bases, dct)
        cls._subclasses = []

        for base in bases:
            if hasattr(base, '_subclasses'):
                base._subclasses.append(cls)

        for key, value in dct.items():
            if callable(value) and getattr(value, "_locked", False):
                setattr(cls, key, cls._create_locked_method(value))

    def _create_locked_method(cls, method):
        """创建一个锁定的方法，防止子类覆盖或调用"""
        def locked_method(self, *args, **kwargs):
            if type(self) != cls:
                raise TypeError(f"Method '{method.__name__}' is locked and cannot be overridden or called by subclasses.")
            return method(self, *args, **kwargs)
        return locked_method

    def all_subclasses(cls):
        all_subs = set(cls._subclasses)
        for subclass in cls._subclasses:
            all_subs.update(subclass.all_subclasses())
        return all_subs

def locked_method(func):
    """装饰器，用于标记需要锁定的方法"""
    func._locked = True
    return func

class Api(metaclass=LockAndSubclassTrackingMeta):
    """
    存储api信息的基类.
    """
    def __init__(self, api_key) -> None:
        self.api_key = api_key
        self.supported_models = self._list_models()
    
    @locked_method
    def get_supported_service_providers(self):
        """
        查看支持哪些服务商.
        """
        all_subclasses = self.all_subclasses()
        supported_service_providers = [cls.__name__.replace('_Api', '') for cls in all_subclasses]
        return supported_service_providers
    
    def get_responses(self, chat, model_list):
        res = {}
        for model_id in model_list:
            res[model_id] = self._get_response(chat, model_id)
        return res
    
    def _list_models(self):
        """
        获取模型列表. 动态向服务商获取.
        """
        raise NotImplementedError("Subclasses should implement this method.")
    
    def _get_response(self, chat, model_list):
        """
        获取model_list的回复.
        """
        raise NotImplementedError("Subclasses should implement this method.")

class OpenAI_agent_Api(Api):
    def __init__(self, api_key) -> None:
        self.conn = http.client.HTTPSConnection("api.chatanywhere.tech")
        super().__init__(api_key)
    
    def _list_models(self):
        payload = ''
        headers = {
            'Authorization': 'Bearer ' + self.api_key,
            'User-Agent': 'Apifox/1.0.0 (https://apifox.com)'
        }
        self.conn.request("GET", "/v1/models", payload, headers)
        res = self.conn.getresponse()
        data = res.read().decode("utf-8")
        data = json.loads(data)['data']
        data = [item['id'] for item in data]
        return data
    
    def _get_response(self, chat, model_id):
        msg_list = [msg.__dict__() for msg in chat.msg_list]
        print(msg_list)
        payload = json.dumps({
            "model": model_id,
            "messages": msg_list
        })
        headers = {
            'Authorization': 'Bearer ' + self.api_key,
            'User-Agent': 'Apifox/1.0.0 (https://apifox.com)',
            'Content-Type': 'application/json'
        }
        self.conn.request("POST", "/v1/chat/completions", payload, headers)
        res = self.conn.getresponse()
        data = res.read().decode("utf-8")
        data = json.loads(data)
        data = data['choices'][0]['message']['content']

        return data
    
# OpenAI_agent = OpenAI_agent_Api(api_key='sk-ux7KAUS9M4FT38beJxfAq0G5W0XMHhshm9txd2ULG4UAKgOV')
# print(OpenAI_agent.supported_models)

# chat = [
#     {
#         "role": "system",
#         "content": "You are a helpful assistant."
#     },
#     {
#         "role": "user",
#         "content": "Hello!"
#     }
# ]
# responses = OpenAI_agent.get_responses(chat, ['gpt-3.5-turbo-ca', 'gpt-3.5-turbo-0301'])
# print(responses)