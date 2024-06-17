from concurrent.futures import ThreadPoolExecutor
import http.client
import json
import os
from openai import OpenAI
import requests
from bs4 import BeautifulSoup

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
    def __init__(self, api_key=None) -> None:
        self.api_key = api_key
        self.supported_models = self._list_models()
    
    @staticmethod
    @locked_method
    def get_provider_models():
        supported_service_providers = Api._get_supported_service_providers()
        provider_models = {provider: eval(f"{provider}_Api").supported_models for provider in supported_service_providers}
        return provider_models

    @staticmethod
    @locked_method
    def _get_supported_service_providers():
        """
        查看支持哪些服务商.
        """
        all_subclasses = Api.all_subclasses()
        supported_service_providers = [cls.__name__.replace('_Api', '') for cls in all_subclasses]
        return supported_service_providers
    
    def get_responses(self, chat, model_list):
        with ThreadPoolExecutor() as executor:
            futures = [executor.submit(self._get_response, chat, model_id) for model_id in model_list]
        
        res = [f.result() for f in futures]
        return res
    
    def _list_models(self):
        """
        获取模型列表. 动态向服务商获取.
        """
        raise NotImplementedError("Subclasses should implement this method.")
    
    def _get_response(self, chat, model_list, api_key):
        """
        获取model_list的回复.
        """
        raise NotImplementedError("Subclasses should implement this method.")

class OpenAI_agent_Api(Api):
    def __init__(self, api_key) -> None:
        super().__init__(api_key=api_key)
        self.client = OpenAI(
            api_key=self.api_key,
            base_url="https://api.chatanywhere.tech/v1",
        )
    
    def _list_models(self):
        conn = http.client.HTTPSConnection("api.chatanywhere.tech")
        payload = ''
        headers = {
            'Authorization': 'Bearer ' + self.api_key,
            'User-Agent': 'Apifox/1.0.0 (https://apifox.com)'
        }
        conn.request("GET", "/v1/models", payload, headers)
        res = conn.getresponse()
        data = res.read().decode("utf-8")
        data = json.loads(data)['data']
        data = [item['id'] for item in data]
        return data
    
    def _get_response(self, chat, model_id):
        try:
            msg_list = [msg.to_role_dict() for msg in chat.msg_list]
            completion = self.client.chat.completions.create(
                model=model_id,
                messages=msg_list
            )
            data = {'code': 1, 'message': completion.choices[0].message.content}
        except Exception as e:
            print(e)
            data = {'code': 0, 'message': e}
        return data

class Qwen_Api(Api):
    def __init__(self, api_key) -> None:
        super().__init__(api_key=api_key)
        self.client = OpenAI(
            api_key=self.api_key,
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
        )

    def _list_models(self):
        url = "https://help.aliyun.com/zh/dashscope/developer-reference/compatibility-of-openai-with-dashscope/"
        response = requests.get(url)
        if response.status_code == 200:
            soup = BeautifulSoup(response.text, 'html.parser')
            
            table = soup.find('table', class_='table')

            models = []
            for row in table.tbody.find_all('tr'):
                cols = row.find_all('td')
                if cols: 
                    cells = cols[1].find_all('p')
                    for cell in cells:
                        model_name = cell.text.strip()
                        models.append(model_name)

            return models[1:]
        else:
            print("Failed to retrieve the webpage")
            return []

    def _get_response(self, chat, model_id):
        try:
            msg_list = [msg.to_role_dict() for msg in chat.msg_list]
            completion = self.client.chat.create(
                model=model_id,
                messages=msg_list
            )
            data = {'code': 1, 'message': completion.choices[0].message.content}
        except Exception as e:
            print(e)
            data = {'code': 0, 'message': e}
        return data


if __name__ == "__main__":
    OpenAI_agent = OpenAI_agent_Api(api_key='sk-yvEwm4Ho60mnUvzUQSByjc8aCWWUFS4glzEsq02M8EKfJ5Rh')
    print(OpenAI_agent.supported_models)

    chat = [
        {
            "role": "system",
            "content": "You are a helpful assistant."
        },
        {
            "role": "user",
            "content": "写一篇500字作文，主题是“我的家乡”。"
        }
    ]
    # 计时
    import time
    start = time.time()
    responses = OpenAI_agent.get_responses(chat, ['gpt-3.5-turbo', 'gpt-3.5-turbo-0125'])
    end = time.time()

    print(responses)
    print(end - start)