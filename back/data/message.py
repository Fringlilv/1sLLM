class Message:
    """
    存储一条消息.
    """

    def __init__(self, role, name, msg, code):
        self.role = role
        self.name = name
        self.msg = msg
        self.code = code

    def __dict__(self):
        return {'role': self.name, 'content': self.msg}
    
    def to_role_dict(self):
        return {'role': self.role, 'content': self.msg}