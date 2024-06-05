import base64
import hashlib
import json
import random
import time

import data
from flask import Flask, request, session


app = Flask(__name__)
server = data.Sever()


def sever_data_init():
    """
    初始化服务器数据.
    """
    admin = data.User('admin', '123456')
    server.add_user(admin)


def gen_session_id(username):
    """
    生成session_id.
    """
    txt = username + str(time.time())
    sid = hashlib.md5(txt.encode('utf-8')).hexdigest()
    return sid


def gen_chat_id(username):
    """
    生成chat_id.
    """
    txt = username + time.strftime('%Y_%m_%d_%H_%M_%S',
                                   time.localtime()) + str(random.randint(0, 100))
    cid = hashlib.md5(txt.encode('utf-8')).hexdigest()
    return cid


def get_user(uname, sid):
    """
    检查session_id.
    """
    if uname is None or sid is None:
        return None
    if server.session_dict.get(uname) == sid:
        return server.user_list[server.user_dict[uname]]
    return None


def get_chat(user, cid):
    """
    获取chat.
    """
    chat_id = user.chat_dict.get(cid)
    if chat_id is None:
        return None
    return user.chat_list[chat_id]


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
    sid = gen_session_id(username)
    server.session_dict[username] = sid
    # 客户端cookie中记录会话信息
    session['username'] = 'admin'
    session['session_id'] = sid
    return 'success', 200


@app.route('/api/list')
def api_list():
    """
    获取api列表.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    ret = {}
    for api in user.api_list:
        ret[api.model_name] = api.api_key
    return json.dumps(ret), 200


@app.route('/api/add')
def api_add():
    """
    添加api.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    model_name = base64.b64decode(request.args.get('name')).decode('utf-8')
    api_key = base64.b64decode(request.args.get('key')).decode('utf-8')
    api = data.Api(model_name, api_key)
    user.add_api(api)
    return 'success', 200


@app.route('/api/del')
def api_del():
    """
    删除api.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    model_name = base64.b64decode(request.args.get('name')).decode('utf-8')
    api_id = user.api_dict[model_name]
    if api_id is None:
        return 'invalid_model_name', 403
    user.api_list.pop(api_id)
    del user.api_dict[model_name]
    return 'success', 200


@app.route('/chat/list')
def chat_list():
    """
    获取会话列表.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    ret = {}
    for chat in user.chat_list:
        ret[chat.chat_id] = chat.chat_title
    return json.dumps(ret), 200


@app.route('/chat/new')
def chat_new():
    """
    新建会话.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    # 生成chat_id
    cid = gen_chat_id(user.username)
    chat = data.Chat(cid, '无标题的聊天')
    user.add_chat(chat)
    return cid, 200


@app.route('/chat/get')
def chat_get():
    """
    获取会话内容.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    chat = get_chat(user, request.args.get('cid'))
    if chat is None:
        return 'invalid_chat_id', 403
    msg_list = []
    for i, sm in enumerate(chat.send_msg_list):
        msg_list.append(sm)
        if i < len(chat.recv_msg_list):
            msg_list.append(chat.recv_msg_list[i])
    return json.dumps(msg_list), 200


@app.route('/chat/del')
def chat_del():
    """
    删除会话.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    chat = get_chat(user, request.args.get('cid'))
    if chat is None:
        return 'invalid_chat_id', 403
    user.chat_list.pop(user.chat_dict[chat.chat_id])
    del user.chat_dict[chat.chat_id]
    return 'success', 200


@app.route('/chat/gen')
def chat_gen():
    """
    生成聊天内容.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    chat = get_chat(user, request.args.get('cid'))
    if chat is None:
        return 'invalid_chat_id', 403
    prompt = base64.b64decode(request.args.get('p')).decode('utf-8')
    models = json.loads(base64.b64decode(
        request.args.get('ml')).decode('utf-8'))
    chat.send_msg_list.append(prompt)
    ans = {}
    # TODO: 生成答复并暂存
    for model_name in models:
        ans[model_name] = '111'
    return json.dumps(ans), 200


@app.route('/chat/regen')
def chat_regen():
    """
    重新生成聊天内容.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    chat = get_chat(user, request.args.get('cid'))
    if chat is None:
        return 'invalid_chat_id', 403
    prompt = chat.send_msg_list[-1]
    models = json.loads(base64.b64decode(
        request.args.get('ml')).decode('utf-8'))
    ans = {}
    # TODO: 生成答复并暂存
    for model_name in models:
        ans[model_name] = '111'
    return json.dumps(ans), 200


@app.route('/chat/sel')
def chat_sel():
    """
    选择答复.
    """
    user = get_user(session.get('username'), session.get('session_id'))
    if user is None:
        return 'invalid_user', 403
    chat = get_chat(user, request.args.get('cid'))
    if chat is None:
        return 'invalid_chat_id', 403
    model_name = base64.b64decode(request.args.get('name')).decode('utf-8')
    chat.recv_msg_list.append(
        chat.recv_msg_list_tmp[chat.recv_model_dict_tmp[model_name]])
    return 'success', 200


if __name__ == '__main__':
    sever_data_init()
    app.secret_key = '123456'
    app.run('0.0.0.0', port=8000, debug=True)
