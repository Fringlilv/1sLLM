import base64
import hashlib
import json
import random
import time

import data
from flask import Flask, request, session, redirect
from flask_cors import CORS


app = Flask(__name__)
CORS(app, supports_credentials=True)
server = data.Sever()

@app.route('/')
def index():
    """
    主页.
    """
    return redirect('/static/index.html')

@app.route('/login')
def login():
    """
    登录.
    """
    username = request.args.get('user')
    password = request.args.get('pd')
    # TODO: check username and password
    print(f'Login: {username}, {password}')
    # 服务器上记录会话信息
    sid = server.gen_session_id('admin')
    server.session_dict['admin'] = sid
    # 客户端cookie中记录会话信息
    session['username'] = 'admin'
    session['session_id'] = sid
    return json.dumps('success'), 200


@app.route('/api/list')
def api_list():
    """
    获取api列表.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    return json.dumps(user.api_dict), 200


@app.route('/api/add')
def api_add():
    """
    添加api.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    service_provider_name = base64.b64decode(request.args.get('name')).decode('utf-8')
    api_key = base64.b64decode(request.args.get('key')).decode('utf-8')
    user.add_api(service_provider_name, api_key)
    return json.dumps('success'), 200


@app.route('/api/del')
def api_del():
    """
    删除api.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    model_name = base64.b64decode(request.args.get('name')).decode('utf-8')
    if model_name not in user.api_dict:
        return json.dumps('invalid_model_name'), 403
    user.del_api(model_name)
    return json.dumps('success'), 200


@app.route('/chat/list')
def chat_list():
    """
    获取会话列表.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    return json.dumps(user.chat_dict, default=lambda o: o.__dict__()), 200


@app.route('/chat/new')
def chat_new():
    """
    新建会话.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    # 生成chat_id
    print(user.username)
    cid = server.gen_chat_id(user.username)
    chat = data.Chat(cid, '无标题的聊天')
    user.add_chat(chat)
    return json.dumps(cid), 200


@app.route('/chat/get')
def chat_get():
    """
    获取会话内容.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    chat = server.get_chat(user, request.args.get('cid'))
    if chat is None:
        return json.dumps('invalid_chat_id'), 403
    return json.dumps(chat, default=lambda o: o.__dict__()), 200


@app.route('/chat/del')
def chat_del():
    """
    删除会话.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    chat = server.get_chat(user, request.args.get('cid'))
    if chat is None:
        return json.dumps('invalid_chat_id'), 403
    user.chat_list.pop(user.chat_dict[chat.chat_id])
    del user.chat_dict[chat.chat_id]
    return json.dumps('success'), 200


@app.route('/chat/gen')
def chat_gen():
    """
    生成聊天内容.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    chat = server.get_chat(user, request.args.get('cid'))
    if chat is None:
        return json.dumps('invalid_chat_id'), 403
    prompt = base64.b64decode(request.args.get('p')).decode('utf-8')
    if prompt == '':
        prompt = chat.recv_msg_list[-1].msg
    models = json.loads(base64.b64decode(
        request.args.get('ml')).decode('utf-8'))
    send_msg = data.Message('system', prompt)
    chat.add_msg(send_msg)
    # TODO: 生成答复并暂存
    # for model_name in models:
    #     api = user.api_dict[model_name]
    #     recv_msg = data.Message(model_name, 'echo: unknown_model')
    #     if api is not None:
    #         recv_msg.msg = api.get_response(chat)
    #     chat.add_recv_msg(model_name, recv_msg)
    # return json.dumps(chat.recv_msg_tmp, default=lambda o: o.__dict__()), 200
    
    for service_provider_name in user.api_dict:
        api_key = user.api_dict[service_provider_name]
        model_list = set(user.available_models[service_provider_name]) & set(models)
        if model_list:
            api = eval(f"data.{service_provider_name}_Api")(api_key)
            responses = api.get_responses(chat, model_list)
            print(responses)
            for model_id in responses:
                recv_msg = data.Message(model_id, responses[model_id])
                chat.add_recv_msg(service_provider_name, recv_msg)
    return json.dumps(chat.recv_msg_tmp, default=lambda o: o.__dict__()), 200


@app.route('/chat/regen')
def chat_regen():
    """
    重新生成聊天内容.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    chat = server.get_chat(user, request.args.get('cid'))
    if chat is None:
        return json.dumps('invalid_chat_id'), 403
    prompt = chat.recv_msg_list[-1].msg
    models = json.loads(base64.b64decode(
        request.args.get('ml')).decode('utf-8'))
    # TODO: 生成答复并暂存
    for model_name in models:
        api = user.api_dict[model_name]
        recv_msg = data.Message(model_name, 'echo: unknown_model')
        if api is not None:
            recv_msg.msg = api.get_response(chat)
        chat.add_recv_msg(model_name, recv_msg)
    return json.dumps(chat.recv_msg_tmp, default=lambda o: o.__dict__()), 200


@app.route('/chat/sel')
def chat_sel():
    """
    选择答复.
    """
    user = server.get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return json.dumps('invalid_user'), 403
    chat = server.get_chat(user, request.args.get('cid'))
    if chat is None:
        return json.dumps('invalid_chat_id'), 403
    model_name = base64.b64decode(request.args.get('name')).decode('utf-8')
    if model_name not in chat.recv_msg_tmp:
        return json.dumps('invalid_model_name'), 403
    chat.sel_recv_msg(model_name)
    return json.dumps('success'), 200


if __name__ == '__main__':
    # admin配置
    admin = data.User('admin', '123456')
    admin.add_api('OpenAI_agent', 'sk-ux7KAUS9M4FT38beJxfAq0G5W0XMHhshm9txd2ULG4UAKgOV')
    server.add_user(admin)
    # 启动服务器
    app.secret_key = '123456'
    app.run('0.0.0.0', port=8000, debug=True)
