from typing import Any
import pymongo
import redis
import json

class DB:
    db = pymongo.MongoClient('mongodb://localhost:27017')['1sLLM']
    redis_client = redis.Redis(host='localhost', port=6379, db=0)
    
    def __init__(self, set_name=None) -> None:
        if set_name is None:
            raise ValueError("set_name must be provided.")
        self.db_set = DB.db[set_name]
        self._db_id = None

    def save(self):
        DB.redis_client.set(self._db_id, json.dumps(self._db_dict()))
        self.db_set.update_one({'_id': self._db_id}, {'$set': self._db_dict()}, upsert=True)

    def delete(self):
        DB.redis_client.delete(self._db_id)
        self.db_set.delete_one({'_id': self._db_id})

    def _db_dict(self):
        raise NotImplementedError("Subclasses should implement this method.")
    
    def _get_from_cache(self, field):
        cached_data = DB.redis_client.get(self._db_id)
        if cached_data:
            data = json.loads(cached_data)
            return data.get(field)
        else:
            record = self.db_set.find_one({'_id': self._db_id}, {field: 1})
            if record:
                DB.redis_client.set(self._db_id, json.dumps(record))
                return record.get(field)
            else:
                raise ValueError(f"Record with id {self._db_id} not found")
    
    def _update_cache(self):
        DB.redis_client.set(self._db_id, json.dumps(self._db_dict()))

    def get_field(self, field):
        return self._get_from_cache(field)

    def set_field(self, field, value):
        setattr(self, f"_{field}", value)
        self.save()

def cached_property(func):
    def wrapper(self, *args, **kwargs):
        return self.get_field(func.__name__[4:])
    return wrapper

def synced_property(func):
    def wrapper(self, *args, **kwargs):
        result = func(self, *args, **kwargs)
        self.save()
        return result
    return wrapper
